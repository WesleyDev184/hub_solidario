using System.Net;
using api.DB;
using api.Modules.Items.Dto;
using api.Modules.Stocks.Dto;
using api.Modules.Stocks.Entity;
using Microsoft.EntityFrameworkCore;


namespace api.Modules.Stocks;

public static class StockService
{
  public static async Task<ResponseStockDTO> CreateStock(
        RequestCreateStockDto request,
        ApiDbContext context,
        CancellationToken ct)
  {
    if (string.IsNullOrWhiteSpace(request.Title))
    {
      return new ResponseStockDTO(
          HttpStatusCode.BadRequest,
          null,
          "Title is required");
    }

    // Verifica se já existe um estoque com este título, ativo ou inativo
    var existingStock = await context.Stocks.AsNoTracking()
        .AnyAsync(s => s.Title == request.Title, ct);

    if (existingStock)
    {
      return new ResponseStockDTO(
            HttpStatusCode.Conflict,
            null,
            "Stock with this title already exists and is active");
    }

    // Cria um novo estoque
    var newStock = new Stock(request.Title);

    context.Stocks.Add(newStock);
    await context.SaveChangesAsync(ct);

    return new ResponseStockDTO(HttpStatusCode.Created, null, "Stock created successfully");
  }

  public static async Task<ResponseStockDTO> GetStock(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
  {
    var stock = await context.Stocks.AsNoTracking()
        .Include(s => s.Items)
        .SingleOrDefaultAsync(s => s.Id == id, ct);

    if (stock == null)
    {
      return new ResponseStockDTO(
          HttpStatusCode.NotFound,
          null,
          "Stock not found");
    }

    var responseStock = new ResponseEntityStockDTO(
        stock.Id,
        stock.Title,
        stock.MaintenanceQtd,
        stock.AvailableQtd,
        stock.BorrowedQtd,
        stock.TotalQtd,
        stock.Items.Select(i => new ResponseEntityItemDTO(
            i.Id,
            i.SeriaCode,
            i.ImageUrl,
            i.Status.ToString(),
            i.CreatedAt)).ToArray(),
        stock.CreatedAt);

    return new ResponseStockDTO(HttpStatusCode.OK, responseStock, "Stock retrieved successfully");
  }

  public static async Task<ResponseStockListDTO> GetStocks(
        ApiDbContext context,
        CancellationToken ct)
  {
    var stocks = await context.Stocks
        .AsNoTracking()
        .Select(s => new ResponseEntityStockDTO(
            s.Id,
            s.Title,
            s.MaintenanceQtd,
            s.AvailableQtd,
            s.BorrowedQtd,
            s.TotalQtd,
            null,
            s.CreatedAt))
        .ToListAsync(ct);

    return new ResponseStockListDTO(HttpStatusCode.OK, stocks.Count, stocks, "Stocks retrieved successfully");
  }

  public static async Task<ResponseStockDTO> UpdateStock(
        Guid id,
        RequestUpdateStockDto request,
        ApiDbContext context,
        CancellationToken ct)
  {
    var stock = await context.Stocks
        .SingleOrDefaultAsync(s => s.Id == id, ct);

    if (stock == null)
    {
      return new ResponseStockDTO(
          HttpStatusCode.NotFound,
          null,
          "Stock not found");
    }

    if (request.Title != null)
    {
      stock.SetTitle(request.Title);
    }

    if (request.MaintenanceQtd.HasValue)
    {
      stock.SetMaintenanceQtd(request.MaintenanceQtd.Value);
    }

    if (request.AvailableQtd.HasValue)
    {
      stock.SetAvailableQtd(request.AvailableQtd.Value);
    }

    if (request.BorrowedQtd.HasValue)
    {
      stock.SetBorrowedQtd(request.BorrowedQtd.Value);
    }

    stock.UpdateTimestamps();

    await context.SaveChangesAsync(ct);

    var responseUpdatedStock = new ResponseEntityStockDTO(
        stock.Id,
        stock.Title,
        stock.MaintenanceQtd,
        stock.AvailableQtd,
        stock.BorrowedQtd,
        stock.TotalQtd,
        stock.Items.Select(i => new ResponseEntityItemDTO(
            i.Id,
            i.SeriaCode,
            i.ImageUrl,
            i.Status.ToString(),
            i.CreatedAt)).ToArray(),
        stock.CreatedAt);

    return new ResponseStockDTO(HttpStatusCode.OK, responseUpdatedStock, "Stock updated successfully");
  }

  public static async Task<ResponseStockDTO> DeleteStock(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
  {
    var stock = await context.Stocks
        .SingleOrDefaultAsync(s => s.Id == id, ct);

    if (stock == null)
    {
      return new ResponseStockDTO(
          HttpStatusCode.NotFound,
          null,
          "Stock not found");
    }

    context.Stocks.Remove(stock);
    await context.SaveChangesAsync(ct);

    return new ResponseStockDTO(HttpStatusCode.NoContent, null, "Stock deleted successfully");
  }

}
