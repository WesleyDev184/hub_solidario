using System.Net;
using api.Auth.Dto;
using api.Auth.Entity;
using api.DB;
using api.Modules.Applicants.Dto;
using api.Modules.Applicants.Entity;
using api.Modules.Items.Dto;
using api.Modules.Items.Entity;
using api.Modules.Items.Enum;
using api.Modules.Stocks.Entity; // Assuming Stock entity for status updates
using api.Modules.Loans.Dto;
using api.Modules.Loans.Entity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Loans;

public static class LoanService
{
  /// <summary>
  /// Creates a new loan record, changes the item's status to UNAVAILABLE, and updates stock quantities.
  /// </summary>
  public static async Task<ResponseLoanDTO> CreateLoan(
    RequestCreateLoanDto request,
    ApiDbContext context,
    UserManager<User> userManager,
    CancellationToken ct)
  {
    if (request.ApplicantId == Guid.Empty ||
        request.ResponsibleId == Guid.Empty ||
        request.ItemId == Guid.Empty ||
        string.IsNullOrWhiteSpace(request.Reason))
    {
      return new ResponseLoanDTO(HttpStatusCode.BadRequest, null, "All required fields must be provided.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      // Verify if the item exists and is AVAILABLE
      var item = await context.Items
        .Include(i => i.Stock) // Include Stock to update its quantities
        .SingleOrDefaultAsync(i => i.Id == request.ItemId, ct);

      if (item == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.NotFound, null, $"Item with ID '{request.ItemId}' not found.");
      }

      if (item.Status != ItemStatus.AVAILABLE)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.Conflict, null,
          $"Item '{item.SeriaCode}' is not available for loan. Current status: {item.Status}.");
      }

      // Verify if Applicant exists (optional, but good for data integrity)
      var applicant = await context.Applicants.SingleOrDefaultAsync(a => a.Id == request.ApplicantId, ct);
      if (applicant == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.NotFound, null,
          $"Applicant with ID '{request.ApplicantId}' not found.");
      }

      var newLoan = new Loan(
        request.ApplicantId,
        request.ResponsibleId,
        request.ItemId,
        request.Reason);

      context.Loans.Add(newLoan);

      // Change item status to UNAVAILABLE and update stock
      UpdateItemStatusAndStock(item, item.Stock, ItemStatus.UNAVAILABLE);

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      ResponseEntityUserDTO? responsibleDto = await userManager.Users
      .Where(u => u.Id == request.ResponsibleId)
      .AsNoTracking() // Use AsNoTracking for better performance if no updates are needed
      .Select(u => new ResponseEntityUserDTO(
        u.Id,
        u.Name ?? string.Empty,
        u.Email ?? string.Empty,
        u.PhoneNumber ?? string.Empty,
        null, // Roles not included here for simplicity, adjust as needed
        u.CreatedAt
      )).SingleOrDefaultAsync(ct);

      var responseLoan = MapToResponseEntityLoanDto(
        newLoan,
        item,
        applicant,
        responsibleDto
      );

      return new ResponseLoanDTO(HttpStatusCode.Created, responseLoan, "Loan created successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error creating loan: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseLoanDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while creating the loan.");
    }
  }

  /// <summary>
  /// Retrieves a single loan by its ID, including related item, applicant, and responsible user details.
  /// </summary>
  public static async Task<ResponseLoanDTO> GetLoan(
    Guid id,
    ApiDbContext context,
    UserManager<User> userManager,
    CancellationToken ct)
  {
    var loan = await context.Loans
      .Include(l => l.Item)
      .Include(l => l.Applicant)
      .AsNoTracking() // Use AsNoTracking for better performance if no updates are needed
      .SingleOrDefaultAsync(l => l.Id == id, ct); // Use SingleOrDefaultAsync directly here

    if (loan == null)
    {
      return new ResponseLoanDTO(HttpStatusCode.NotFound, null, $"Loan with ID '{id}' not found.");
    }

    ResponseEntityUserDTO? responsibleDto = await userManager.Users
      .Where(u => u.Id == loan.ResponsibleId)
      .AsNoTracking() // Use AsNoTracking for better performance if no updates are needed
      .Select(u => new ResponseEntityUserDTO(
        u.Id,
        u.Name ?? string.Empty,
        u.Email ?? string.Empty,
        u.PhoneNumber ?? string.Empty,
        null, // Roles not included here for simplicity, adjust as needed
        u.CreatedAt
      )).SingleOrDefaultAsync(ct);

    var responseLoan = MapToResponseEntityLoanDto(
      loan,
      loan.Item,
      loan.Applicant,
      responsibleDto
    );

    return new ResponseLoanDTO(HttpStatusCode.OK, responseLoan, "Loan retrieved successfully.");
  }

  /// <summary>
  /// Retrieves a list of all active loans, including summarized details of related item, applicant, and responsible user.
  /// </summary>
  public static async Task<ResponseLoanListDTO> GetLoans(
    ApiDbContext context,
    UserManager<User> userManager,
    CancellationToken ct)
  {
    // Select only necessary data to improve performance
    var loansData = await context.Loans.AsNoTracking()
      .Include(l => l.Applicant)
      .Include(l => l.Item)
      .Where(l => l.IsActive)
      .OrderByDescending(l => l.CreatedAt)
      .Select(l => new // Project to an anonymous type first to avoid mapping issues with DTOs directly
      {
        l.Id,
        l.ReturnDate,
        l.Reason,
        l.IsActive,
        l.ResponsibleId,
        ItemSeriaCode = l.Item != null ? l.Item.SeriaCode : 0,
        ApplicantName = l.Applicant != null ? l.Applicant.Name : string.Empty,
        l.CreatedAt
      })
      .ToListAsync(ct);

    if (loansData.Count == 0)
    {
      return new ResponseLoanListDTO(HttpStatusCode.OK, 0, new List<ResponseEntityLoanListDTO>(),
        "No active loans found.");
    }

    // Efficiently fetch all responsible user names in one go
    var responsibleIds = loansData.Select(l => l.ResponsibleId).Distinct().ToList();
    var responsibleNames = await userManager.Users
      .Where(u => responsibleIds.Contains(u.Id))
      .ToDictionaryAsync(u => u.Id, u => u.Name, ct);

    // Map the collected data to the response DTOs
    var responseLoans = loansData.Select(l => new ResponseEntityLoanListDTO(
      l.Id,
      l.ReturnDate,
      l.Reason,
      l.IsActive,
      l.ItemSeriaCode,
      l.ApplicantName,
      responsibleNames.GetValueOrDefault(l.ResponsibleId, string.Empty) ??
      string.Empty, // Handle potential null Name from UserManager
      l.CreatedAt
    )).ToList();

    return new ResponseLoanListDTO(HttpStatusCode.OK, loansData.Count, responseLoans, "Loans retrieved successfully.");
  }

  /// <summary>
  /// Updates an existing loan's information.
  /// </summary>
  public static async Task<ResponseLoanDTO> UpdateLoan(
    Guid id,
    RequestUpdateLoanDto request,
    ApiDbContext context,
    UserManager<User> userManager,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseLoanDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var loan = await context.Loans
        .Include(l => l.Item).ThenInclude(item => item!.Stock) // Include item to potentially update its status
        .Include(l => l.Applicant) // Include applicant for mapping response
        .SingleOrDefaultAsync(l => l.Id == id, ct);

      if (loan == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.NotFound, null, $"Loan with ID '{id}' not found.");
      }

      if (loan.Item == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.InternalServerError, null, "Loan item data is missing.");
      }

      var oldIsActiveStatus = loan.IsActive; // Store old status before updating

      if (!string.IsNullOrWhiteSpace(request.Reason))
      {
        loan.Reason = request.Reason;
      }

      if (request.ReturnDate != null)
      {
        // Accepts ISO 8601, "yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", or "dd/MM/yyyy"
        var formats = new[] {
          "yyyy-MM-dd",
          "yyyy-MM-dd HH:mm:ss",
          "yyyy-MM-ddTHH:mm:ssZ",
          "dd/MM/yyyy"
        };
        if (DateTime.TryParseExact(request.ReturnDate, formats, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.AssumeUniversal, out var returnDate)
            || DateTime.TryParse(request.ReturnDate, out returnDate))
        {
          loan.ReturnDate = returnDate;
        }
        else
        {
          await transaction.RollbackAsync(ct);
          return new ResponseLoanDTO(HttpStatusCode.BadRequest, null, "Invalid Return Date format. Use ISO 8601 (e.g., 2024-06-10T15:30:00Z), yyyy-MM-dd, yyyy-MM-dd HH:mm:ss, or dd/MM/yyyy.");
        }
      }

      if (request.IsActive.HasValue)
      {
        loan.IsActive = request.IsActive.Value;
      }

      // If loan status changed from active to inactive, or vice versa, update item status and stock
      if (request.IsActive.HasValue && request.IsActive.Value != oldIsActiveStatus && loan.Item != null)
      {
        if (loan.IsActive) // Loan became active (e.g., re-activated) -> item should be unavailable
        {
          if (loan.Item.Status != ItemStatus.UNAVAILABLE)
          {
            UpdateItemStatusAndStock(loan.Item, loan.Item.Stock, ItemStatus.UNAVAILABLE);
          }
        }
        else // Loan became inactive (e.g., returned) -> item should be available
        {
          if (loan.Item.Status != ItemStatus.AVAILABLE)
          {
            UpdateItemStatusAndStock(loan.Item, loan.Item.Stock, ItemStatus.AVAILABLE);
          }
        }
      }

      loan.UpdateTimestamps(); // Assuming this sets ModifiedAt
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      ResponseEntityUserDTO? responsibleDto = await userManager.Users
        .Where(u => u.Id == loan.ResponsibleId)
        .AsNoTracking() // Use AsNoTracking for better performance if no updates are needed
        .Select(u => new ResponseEntityUserDTO(
          u.Id,
          u.Name ?? string.Empty,
          u.Email ?? string.Empty,
          u.PhoneNumber ?? string.Empty,
          null, // Roles not included here for simplicity, adjust as needed
          u.CreatedAt
        )).SingleOrDefaultAsync(ct);

      var responseLoan = MapToResponseEntityLoanDto(
        loan,
        loan.Item,
        loan.Applicant,
        responsibleDto
      );

      return new ResponseLoanDTO(HttpStatusCode.OK, responseLoan, "Loan updated successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error updating loan: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseLoanDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while updating the loan.");
    }
  }

  /// <summary>
  /// Deletes a loan record and reverts the associated item's status to AVAILABLE, updating stock quantities.
  /// </summary>
  public static async Task<ResponseLoanDTO> DeleteLoan(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var loan = await context.Loans
        .Include(l => l.Item).ThenInclude(item => item!.Stock)
        .SingleOrDefaultAsync(l => l.Id == id, ct);

      if (loan == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseLoanDTO(HttpStatusCode.NotFound, null, $"Loan with ID '{id}' not found.");
      }

      context.Loans.Remove(loan);

      // Revert item status to AVAILABLE and update stock when loan is deleted
      if (loan.Item != null)
      {
        UpdateItemStatusAndStock(loan.Item, loan.Item.Stock, ItemStatus.AVAILABLE);
      }

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // 200 is standard for successful DELETE operations
      return new ResponseLoanDTO(HttpStatusCode.OK, null, "Loan deleted successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error deleting loan: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseLoanDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while deleting the loan.");
    }
  }

  /// <summary>
  /// Helper method to update an item's status and its corresponding stock quantities.
  /// This logic could also be in a shared 'ItemService' helper if tightly coupled.
  /// </summary>
  private static void UpdateItemStatusAndStock(Item item, Stock? stock, ItemStatus newStatus)
  {
    if (item == null || stock == null) return; // Should not happen if Include is used correctly

    var oldStatus = item.Status;

    // Only proceed if status is actually changing
    if (oldStatus == newStatus) return;

    // Decrement from old status
    switch (oldStatus)
    {
      case ItemStatus.AVAILABLE:
        stock.SetAvailableQtd(stock.AvailableQtd - 1);
        break;
      case ItemStatus.UNAVAILABLE:
        stock.SetBorrowedQtd(stock.BorrowedQtd - 1); // Assuming UNAVAILABLE means borrowed
        break;
      case ItemStatus.MAINTENANCE:
        stock.SetMaintenanceQtd(stock.MaintenanceQtd - 1);
        break;
    }

    // Increment to new status
    item.SetStatus(newStatus); // Update item's status first

    switch (newStatus)
    {
      case ItemStatus.AVAILABLE:
        stock.SetAvailableQtd(stock.AvailableQtd + 1);
        break;
      case ItemStatus.UNAVAILABLE:
        stock.SetBorrowedQtd(stock.BorrowedQtd + 1);
        break;
      case ItemStatus.MAINTENANCE:
        stock.SetMaintenanceQtd(stock.MaintenanceQtd + 1);
        break;
    }
  }

  /// <summary>
  /// Maps a Loan entity, its related Item and Applicant to a ResponseEntityLoanDTO.
  /// </summary>
  private static ResponseEntityLoanDTO MapToResponseEntityLoanDto(
    Loan loan,
    Item? item,
    Applicant? applicant,
    ResponseEntityUserDTO? responsibleUserDto)
  {
    return new ResponseEntityLoanDTO(
      loan.Id,
      loan.ReturnDate,
      loan.Reason,
      loan.IsActive,
      item == null
        ? null
        : new ResponseEntityItemDTO(
          item.Id,
          item.SeriaCode,
          item.Status.ToString(),
          item.StockId,
          item.CreatedAt
        ),
      applicant == null
        ? null
        : new ResponseEntityApplicantsDTO(
          applicant.Id,
          applicant.Name,
          applicant.CPF,
          applicant.Email,
          applicant.PhoneNumber,
          applicant.Address,
          applicant.IsBeneficiary,
          applicant.BeneficiaryQtd,
          applicant.CreatedAt,
          null // Dependents not included in this nested DTO for brevity
        ),
      responsibleUserDto,
      loan.CreatedAt
    );
  }
}