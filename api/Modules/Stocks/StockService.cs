using System.Net;
using api.DB;
using api.Modules.Items.Dto;
using api.Modules.Items.Entity;
using api.Modules.OrthopedicBanks.Dto;
using api.Modules.OrthopedicBanks.Entity;
using api.Modules.Stocks.Dto;
using api.Modules.Stocks.Entity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Stocks;

public static class StockService
{
  /// <summary>
  /// Creates a new stock record.
  /// </summary>
  public static async Task<ResponseStockDTO> CreateStock(
    RequestCreateStockDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseStockDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    if (string.IsNullOrWhiteSpace(request.Title))
    {
      return new ResponseStockDTO(
        HttpStatusCode.BadRequest,
        null,
        "Title is required.");
    }

    // Verify that the associated OrthopedicBank exists
    var orthopedicBank = await context.OrthopedicBanks
      .SingleOrDefaultAsync(ob => ob.Id == request.OrthopedicBankId, ct);

    if (orthopedicBank == null)
    {
      return new ResponseStockDTO(
        HttpStatusCode.NotFound,
        null,
        $"Orthopedic bank with ID '{request.OrthopedicBankId}' not found.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      // Check if a stock with this title already exists
      var existingStock = await context.Stocks.AsNoTracking()
        .AnyAsync(s => s.Title == request.Title, ct);

      if (existingStock)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseStockDTO(
          HttpStatusCode.Conflict,
          null,
          $"Stock with title '{request.Title}' already exists.");
      }

      // Create a new stock with initial quantities set to 0
      var newStock = new Stock(request.Title, request.OrthopedicBankId);

      context.Stocks.Add(newStock);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseStockDTO(HttpStatusCode.Created, MapToResponseEntityStockDto(newStock, null, null), "Stock created successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error creating stock: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseStockDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while creating the stock.");
    }
  }

  /// <summary>
  /// Retrieves a single stock by its ID, including its associated orthopedic bank and items.
  /// </summary>
  public static async Task<ResponseStockDTO> GetStock(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    var stock = await context.Stocks.AsNoTracking()
      .Include(s => s.OrthopedicBank)
      .Include(s => s.Items)
      .SingleOrDefaultAsync(s => s.Id == id, ct);

    if (stock == null)
    {
      return new ResponseStockDTO(HttpStatusCode.NotFound, null, $"Stock with ID '{id}' not found.");
    }

    var responseStock = MapToResponseEntityStockDto(stock, stock.OrthopedicBank, stock.Items.ToList());
    return new ResponseStockDTO(HttpStatusCode.OK, responseStock, "Stock retrieved successfully.");
  }

  /// <summary>
  /// Retrieves a list of all stocks, without including associated items or orthopedic bank details for performance.
  /// </summary>
  public static async Task<ResponseStockListDTO> GetStocks(
    ApiDbContext context,
    CancellationToken ct)
  {
    // Select directly into the DTO for efficiency, without full related entities for list view
    var stocks = await context.Stocks
      .AsNoTracking()
      .Select(s => new ResponseEntityStockDTO(
        s.Id,
        s.Title,
        s.MaintenanceQtd,
        s.AvailableQtd,
        s.BorrowedQtd,
        s.TotalQtd,
        null, // OrthopedicBank not included in list view for brevity/performance
        null, // Items not included in list view for brevity/performance
        s.CreatedAt))
      .ToListAsync(ct);

    // Return 200 OK with an empty list if no stocks are found, not 404
    return new ResponseStockListDTO(HttpStatusCode.OK, stocks.Count, stocks, "Stocks retrieved successfully.");
  }

  /// <summary>
  /// Retrieves a list of all stocks for a specific orthopedic bank.
  /// </summary>
  public static async Task<ResponseStockListDTO> GetStocksByOrthopedicBank(
    Guid orthopedicBankId,
    ApiDbContext context,
    CancellationToken ct)
  {
    // Verify that the associated OrthopedicBank exists
    var orthopedicBankExists = await context.OrthopedicBanks
      .AsNoTracking()
      .AnyAsync(ob => ob.Id == orthopedicBankId, ct);

    if (!orthopedicBankExists)
    {
      return new ResponseStockListDTO(
        HttpStatusCode.NotFound,
        0,
        new List<ResponseEntityStockDTO>(),
        $"Orthopedic bank with ID '{orthopedicBankId}' not found.");
    }

    var stocks = await context.Stocks
      .AsNoTracking()
      .Where(s => s.OrthopedicBankId == orthopedicBankId)
      .Select(s => new ResponseEntityStockDTO(
        s.Id,
        s.Title,
        s.MaintenanceQtd,
        s.AvailableQtd,
        s.BorrowedQtd,
        s.TotalQtd,
        null, // OrthopedicBank not included in list view for brevity/performance
        null, // Items not included in list view for brevity/performance
        s.CreatedAt))
      .ToListAsync(ct);

    return new ResponseStockListDTO(
      HttpStatusCode.OK,
      stocks.Count,
      stocks,
      $"Stocks for orthopedic bank {orthopedicBankId} retrieved successfully.");
  }

  /// <summary>
  /// Updates an existing stock's information.
  /// </summary>
  public static async Task<ResponseStockDTO> UpdateStock(
    Guid id,
    RequestUpdateStockDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseStockDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var stock = await context.Stocks
        .SingleOrDefaultAsync(s => s.Id == id, ct);

      if (stock == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseStockDTO(HttpStatusCode.NotFound, null, $"Stock with ID '{id}' not found.");
      }

      // Only update if the request property is not null/empty AND different from current value
      if (!string.IsNullOrWhiteSpace(request.Title) && request.Title != stock.Title)
      {
        // Check for duplicate title if it's being changed
        var existingStockWithSameTitle = await context.Stocks.AsNoTracking()
          .AnyAsync(s => s.Title == request.Title && s.Id != id, ct);

        if (existingStockWithSameTitle)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseStockDTO(HttpStatusCode.Conflict, null,
            $"Stock with title '{request.Title}' already exists.");
        }

        stock.SetTitle(request.Title);
      }

      if (request.MaintenanceQtd.HasValue)
      {
        if (request.MaintenanceQtd.Value < 0)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseStockDTO(HttpStatusCode.BadRequest, null, "Maintenance quantity cannot be negative.");
        }

        stock.SetMaintenanceQtd(request.MaintenanceQtd.Value);
      }

      if (request.AvailableQtd.HasValue)
      {
        if (request.AvailableQtd.Value < 0)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseStockDTO(HttpStatusCode.BadRequest, null, "Available quantity cannot be negative.");
        }

        stock.SetAvailableQtd(request.AvailableQtd.Value);
      }

      if (request.BorrowedQtd.HasValue)
      {
        if (request.BorrowedQtd.Value < 0)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseStockDTO(HttpStatusCode.BadRequest, null, "Borrowed quantity cannot be negative.");
        }

        stock.SetBorrowedQtd(request.BorrowedQtd.Value);
      }

      stock.UpdateTimestamps(); // Assuming this updates the ModifiedAt timestamp

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseStockDTO(HttpStatusCode.OK, MapToResponseEntityStockDto(stock, null, null), "Stock updated successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error updating stock: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseStockDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while updating the stock.");
    }
  }

  /// <summary>
  /// Deletes a stock record. This operation will fail if the stock has associated items.
  /// </summary>
  public static async Task<ResponseStockDTO> DeleteStock(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var stock = await context.Stocks
        .Include(s => s.Items) // Eager load items to check for existence
        .SingleOrDefaultAsync(s => s.Id == id, ct);

      if (stock == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseStockDTO(HttpStatusCode.NotFound, null, $"Stock with ID '{id}' not found.");
      }

      // Business rule: Prevent deletion if there are associated items
      if (stock.Items != null && stock.Items.Count != 0)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseStockDTO(
          HttpStatusCode.BadRequest,
          null,
          $"Stock with ID '{id}' cannot be deleted because it has associated items. Please delete or reassign items first.");
      }

      context.Stocks.Remove(stock);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // 204 No Content is standard for successful DELETE operations where no content is returned
      return new ResponseStockDTO(HttpStatusCode.OK, null, "Stock deleted successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error deleting stock: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseStockDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while deleting the stock.");
    }
  }

  /// <summary>
  /// Maps a Stock entity to a ResponseEntityStockDTO, including mapped related entities.
  /// </summary>
  private static ResponseEntityStockDTO MapToResponseEntityStockDto(
    Stock stock,
    OrthopedicBank? orthopedicBank, // Use full namespace to avoid conflict if OrthopedicBank is also a DTO
    List<Item>? items) // Use full namespace for Item entity
  {
    return new ResponseEntityStockDTO(
      stock.Id,
      stock.Title,
      stock.MaintenanceQtd,
      stock.AvailableQtd,
      stock.BorrowedQtd,
      stock.TotalQtd,
      orthopedicBank == null
        ? null
        : new ResponseEntityOrthopedicBankDTO(
          orthopedicBank.Id,
          orthopedicBank.Name,
          orthopedicBank.City,
          null,
          orthopedicBank.CreatedAt), // No need for null on CreateAt here.
      items?.Select(i => new ResponseEntityItemDTO(
        i.Id,
        i.SeriaCode,
        i.ImageUrl,
        i.Status.ToString(),
        i.StockId,
        i.CreatedAt)).ToArray(),
      stock.CreatedAt
    );
  }
}