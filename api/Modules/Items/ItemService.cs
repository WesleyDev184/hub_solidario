using api.DB;
using api.Modules.Items.Dto;
using api.Modules.Items.Entity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Items;

public static class ItemService
{

  public static async Task<ResponseItemDTO> CreateItem(
      RequestCreateItemDto request,
      ApiDbContext context,
      CancellationToken ct)
  {
    var stock = await context.Stocks
        .AsNoTracking()
        .SingleOrDefaultAsync(s => s.Id == request.StockId, ct);

    if (stock == null)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.NotFound,
          null,
          "Stock not found");
    }

    if (request.SeriaCode <= 0)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.BadRequest,
          null,
          "Seria code must be greater than zero");
    }

    var existingItem = await context.Items.AsNoTracking()
        .SingleOrDefaultAsync(i => i.SeriaCode == request.SeriaCode, ct);

    if (existingItem != null)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.Conflict,
          null,
          "Item with the same seria code already exists");
    }

    var newItem = new Item(request.SeriaCode, request.ImageUrl, request.Status, request.StockId);

    context.Items.Add(newItem);
    await context.SaveChangesAsync(ct);

    var responseNewItem = new ResponseEntityItemDTO(
        newItem.Id,
        newItem.SeriaCode,
        newItem.ImageUrl,
        newItem.Status.ToString(),
        newItem.CreatedAt);

    return new ResponseItemDTO(System.Net.HttpStatusCode.Created, responseNewItem, "Item created successfully");
  }

  public static async Task<ResponseItemDTO> GetItem(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
  {
    var item = await context.Items.AsNoTracking().SingleOrDefaultAsync(
        i => i.Id == id,
        ct
    );

    if (item == null)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.NotFound,
          null,
          "Item not found");
    }

    var responseItem = new ResponseEntityItemDTO(
        item.Id,
        item.SeriaCode,
        item.ImageUrl,
        item.Status.ToString(),
        item.CreatedAt);

    return new ResponseItemDTO(System.Net.HttpStatusCode.OK, responseItem, "Item retrieved successfully");
  }

  public static async Task<ResponseItemListDTO> GetItems(
      ApiDbContext context,
      CancellationToken ct)
  {
    var items = await context.Items.AsNoTracking()
        .Select(i => new ResponseEntityItemDTO(
            i.Id,
            i.SeriaCode,
            i.ImageUrl,
            i.Status.ToString(),
            i.CreatedAt))
        .ToListAsync(ct);

    return new ResponseItemListDTO(System.Net.HttpStatusCode.OK, items.Count, items, "Items retrieved successfully");
  }

  public static async Task<ResponseItemDTO> UpdateItem(
      Guid id,
      RequestUpdateItemDto request,
      ApiDbContext context,
      CancellationToken ct)
  {
    var item = await context.Items.SingleOrDefaultAsync(
        i => i.Id == id,
        ct
    );

    if (item == null)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.NotFound,
          null,
          "Item not found");
    }

    if (request.SeriaCode != null)
    {
      if (request.SeriaCode <= 0)
      {
        return new ResponseItemDTO(
            System.Net.HttpStatusCode.BadRequest,
            null,
            "Seria code must be greater than zero");
      }
      item.SetSeriaCode(request.SeriaCode.Value);
    }

    if (!string.IsNullOrWhiteSpace(request.ImageUrl))
    {
      item.SetImageUrl(request.ImageUrl);
    }

    if (request.Status != null)
    {
      item.SetStatus(request.Status.Value);
    }

    item.UpdateTimestamps();

    await context.SaveChangesAsync(ct);

    var responseUpdatedItem = new ResponseEntityItemDTO(
        item.Id,
        item.SeriaCode,
        item.ImageUrl,
        item.Status.ToString(),
        item.CreatedAt);

    return new ResponseItemDTO(System.Net.HttpStatusCode.OK, responseUpdatedItem, "Item updated successfully");
  }

  public static async Task<ResponseItemDTO> DeleteItem(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
  {
    var item = await context.Items.SingleOrDefaultAsync(
        i => i.Id == id,
        ct
    );

    if (item == null)
    {
      return new ResponseItemDTO(
          System.Net.HttpStatusCode.NotFound,
          null,
          "Item not found");
    }

    context.Items.Remove(item);
    await context.SaveChangesAsync(ct);

    return new ResponseItemDTO(System.Net.HttpStatusCode.NoContent, null, "Item deleted successfully");
  }

}
