using System.Net;
using api.DB;
using api.Modules.OrthopedicBanks.Dto;
using api.Modules.OrthopedicBanks.Entity;
using api.Modules.Stocks.Dto;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankService
{
  /// <summary>
  /// Creates a new orthopedic bank.
  /// </summary>
  public static async Task<ResponseOrthopedicBankDTO> CreateOrthopedicBank(
    RequestCreateOrthopedicBankDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.City))
    {
      return new ResponseOrthopedicBankDTO(
        HttpStatusCode.BadRequest,
        null,
        "Name and City are required fields.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      // Check if an orthopedic bank with this name already exists
      var existingBank = await context.OrthopedicBanks.AsNoTracking()
        .AnyAsync(b => b.Name.ToLower() == request.Name.ToLower(), ct);

      if (existingBank)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseOrthopedicBankDTO(
          HttpStatusCode.Conflict,
          null,
          $"Orthopedic bank with name '{request.Name}' already exists.");
      }

      var newBank = new OrthopedicBank(request.Name, request.City);

      context.OrthopedicBanks.Add(newBank);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseOrthopedicBankDTO(HttpStatusCode.Created, MapToResponseEntityOrthopedicBankDto(newBank),
        "Orthopedic bank created successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error creating orthopedic bank: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseOrthopedicBankDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while creating the orthopedic bank.");
    }
  }

  /// <summary>
  /// Retrieves a single orthopedic bank by its ID.
  /// </summary>
  public static async Task<ResponseOrthopedicBankDTO> GetOrthopedicBank(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    var orthopedicBank = await context.OrthopedicBanks.AsNoTracking()
      .Include(b => b.Stocks) // Include related stocks
      .SingleOrDefaultAsync(b => b.Id == id, ct);

    if (orthopedicBank == null)
    {
      return new ResponseOrthopedicBankDTO(HttpStatusCode.NotFound, null, $"Orthopedic bank with ID '{id}' not found.");
    }

    var responseBank = MapToResponseEntityOrthopedicBankDto(orthopedicBank);
    return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, responseBank, "Orthopedic bank retrieved successfully.");
  }

  /// <summary>
  /// Retrieves a list of all orthopedic banks.
  /// </summary>
  public static async Task<ResponseOrthopedicBankListDTO> GetOrthopedicBanks(
    ApiDbContext context,
    CancellationToken ct)
  {
    var orthopedicBanks = await context.OrthopedicBanks.AsNoTracking()
      .Select(b => MapToResponseEntityOrthopedicBankDto(b)) // Use mapping helper
      .ToListAsync(ct);

    // Return 200 OK with an empty list if no banks are found, not 404
    return new ResponseOrthopedicBankListDTO(HttpStatusCode.OK, orthopedicBanks.Count, orthopedicBanks,
      "Orthopedic banks retrieved successfully.");
  }

  /// <summary>
  /// Updates an existing orthopedic bank's information.
  /// </summary>
  public static async Task<ResponseOrthopedicBankDTO> UpdateOrthopedicBank(
    Guid id,
    RequestUpdateOrthopedicBankDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseOrthopedicBankDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var orthopedicBank = await context.OrthopedicBanks
        .SingleOrDefaultAsync(b => b.Id == id, ct);

      if (orthopedicBank == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseOrthopedicBankDTO(HttpStatusCode.NotFound, null,
          $"Orthopedic bank with ID '{id}' not found.");
      }

      // Only update if the request property is not null/empty AND different from current value
      if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != orthopedicBank.Name)
      {
        // Check for duplicate name if it's being changed
        var existingBankWithSameName = await context.OrthopedicBanks.AsNoTracking()
          .AnyAsync(b => b.Name.ToLower() == request.Name.ToLower() && b.Id != id, ct);

        if (existingBankWithSameName)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseOrthopedicBankDTO(HttpStatusCode.Conflict, null,
            $"Orthopedic bank with name '{request.Name}' already exists.");
        }

        orthopedicBank.SetName(request.Name);
      }

      if (!string.IsNullOrWhiteSpace(request.City))
      {
        orthopedicBank.SetCity(request.City);
      }

      orthopedicBank.UpdateTimestamps(); // Assuming this updates the ModifiedAt timestamp

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, MapToResponseEntityOrthopedicBankDto(orthopedicBank),
        "Orthopedic bank updated successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error updating orthopedic bank: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseOrthopedicBankDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while updating the orthopedic bank.");
    }
  }

  /// <summary>
  /// Deletes an orthopedic bank from the database.
  /// </summary>
  public static async Task<ResponseOrthopedicBankDTO> DeleteOrthopedicBank(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var orthopedicBank = await context.OrthopedicBanks
        .Include(b => b.Stocks) // Include related stocks if needed for business rules
        .SingleOrDefaultAsync(b => b.Id == id, ct);

      if (orthopedicBank == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseOrthopedicBankDTO(HttpStatusCode.NotFound, null,
          $"Orthopedic bank with ID '{id}' not found.");
      }


      if (orthopedicBank.Stocks.Any())
      {
        await transaction.RollbackAsync(ct);
        return new ResponseOrthopedicBankDTO(HttpStatusCode.BadRequest, null,
          $"Orthopedic bank with ID '{id}' cannot be deleted because it has associated stock/items.");
      }


      context.OrthopedicBanks.Remove(orthopedicBank);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // 204 No Content is standard for successful DELETE operations where no content is returned
      return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, null, "Orthopedic bank deleted successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error deleting orthopedic bank: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseOrthopedicBankDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while deleting the orthopedic bank.");
    }
  }

  /// <summary>
  /// Maps an OrthopedicBank entity to a ResponseEntityOrthopedicBankDTO.
  /// </summary>
  private static ResponseEntityOrthopedicBankDTO MapToResponseEntityOrthopedicBankDto(OrthopedicBank orthopedicBank)
  {
    return new ResponseEntityOrthopedicBankDTO(
      orthopedicBank.Id,
      orthopedicBank.Name,
      orthopedicBank.City,
      orthopedicBank.Stocks.Select(s => new ResponseEntityStockDTO(
        s.Id,
        s.Title,
        s.MaintenanceQtd,
        s.AvailableQtd,
        s.BorrowedQtd,
        s.TotalQtd,
        null,
        null,
        s.CreatedAt
      )).ToArray(),
      orthopedicBank.CreatedAt
    );
  }
}