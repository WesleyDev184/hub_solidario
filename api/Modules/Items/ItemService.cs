using api.DB;
using api.Modules.Items.Dto;
using api.Modules.Items.Entity;
using api.Modules.Items.Enum;
using api.Modules.Stocks.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System.Net; // For HttpStatusCode

namespace api.Modules.Items
{
  public static class ItemService
  {
    /// <summary>
    /// Creates a new item and updates the associated stock quantity.
    /// </summary>
    public static async Task<ResponseItemDTO> CreateItem(
      RequestCreateItemDto request,
      ApiDbContext context,
      CancellationToken ct)
    {
      // Early exit for null request
      if (request == null)
      {
        return new ResponseItemDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
      }

      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        Stock? stock = await context.Stocks
          .SingleOrDefaultAsync(s => s.Id == request.StockId, ct);

        if (stock == null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseItemDTO(HttpStatusCode.NotFound, null, $"Stock with ID '{request.StockId}' not found.");
        }

        if (request.SeriaCode <= 0)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseItemDTO(HttpStatusCode.BadRequest, null, "Seria code must be greater than zero.");
        }

        Item? existingItem = await context.Items.AsNoTracking()
          .SingleOrDefaultAsync(i => i.SeriaCode == request.SeriaCode, ct);

        if (existingItem != null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseItemDTO(HttpStatusCode.Conflict, null,
            $"Item with seria code '{request.SeriaCode}' already exists.");
        }

        Item newItem = new(request.SeriaCode, ItemStatus.AVAILABLE, request.StockId);

        context.Items.Add(newItem);

        // Increment the available quantity in stock since new items are created as AVAILABLE
        UpdateStockQuantity(stock, ItemStatus.AVAILABLE, 1);

        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        var responseItem = MapToResponseEntityItemDto(newItem);

        return new ResponseItemDTO(HttpStatusCode.Created, responseItem, "Item created successfully.");
      }
      catch
      {
        await transaction.RollbackAsync(ct);
        return new ResponseItemDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while creating the item.");
      }
    }

    /// <summary>
    /// Retrieves a single item by its ID.
    /// </summary>
    public static async Task<ResponseItemDTO> GetItem(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
    {
      Item? item = await context.Items.AsNoTracking().SingleOrDefaultAsync(
        i => i.Id == id,
        ct
      );

      if (item == null)
      {
        return new ResponseItemDTO(HttpStatusCode.NotFound, null, $"Item with ID '{id}' not found.");
      }

      ResponseEntityItemDTO responseItem = MapToResponseEntityItemDto(item);
      return new ResponseItemDTO(HttpStatusCode.OK, responseItem, "Item retrieved successfully.");
    }

    /// <summary>
    /// Retrieves a list of all items.
    /// </summary>
    public static async Task<ResponseItemListDTO> GetItems(
      ApiDbContext context,
      CancellationToken ct)
    {
      List<ResponseEntityItemDTO> items = await context.Items.AsNoTracking()
        .Select(i => MapToResponseEntityItemDto(i))
        .ToListAsync(ct);

      return new ResponseItemListDTO(HttpStatusCode.OK, items.Count, items, "Items retrieved successfully.");
    }

    public static async Task<ResponseItemListDTO> GetItemsByStock(
      Guid stockId,
      ApiDbContext context,
      CancellationToken ct)
    {
      List<ResponseEntityItemDTO> items = await context.Items.AsNoTracking()
        .Where(i => i.StockId == stockId)
        .Select(i => MapToResponseEntityItemDto(i))
        .ToListAsync(ct);

      return new ResponseItemListDTO(HttpStatusCode.OK, items.Count, items, "Items retrieved successfully.");
    }

    /// <summary>
    /// Updates an existing item and its associated stock quantity if the status changes.
    /// </summary>
    public static async Task<ResponseItemDTO> UpdateItem(
      Guid id,
      RequestUpdateItemDto request,
      ApiDbContext context,
      CancellationToken ct)
    {
      // Early exit for null request
      if (request == null)
      {
        return new ResponseItemDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
      }

      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        Item? item = await context.Items.SingleOrDefaultAsync(
          i => i.Id == id,
          ct
        );

        if (item == null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseItemDTO(HttpStatusCode.NotFound, null, $"Item with ID '{id}' not found.");
        }

        // Seria Code validation and update
        if (request.SeriaCode.HasValue)
        {
          if (request.SeriaCode.Value <= 0)
          {
            await transaction.RollbackAsync(ct);
            return new ResponseItemDTO(HttpStatusCode.BadRequest, null, "Seria code must be greater than zero.");
          }

          // Check for duplicate seria code if it's being changed
          if (request.SeriaCode.Value != item.SeriaCode)
          {
            bool existingItemWithSameSeriaCode = await context.Items.AsNoTracking()
              .AnyAsync(i => i.SeriaCode == request.SeriaCode.Value && i.Id != id, ct);

            if (existingItemWithSameSeriaCode)
            {
              await transaction.RollbackAsync(ct);
              return new ResponseItemDTO(HttpStatusCode.Conflict, null,
                $"Another item with seria code '{request.SeriaCode.Value}' already exists.");
            }
          }

          item.SetSeriaCode(request.SeriaCode.Value);
        }

        // Store old status before potential update
        ItemStatus oldStatus = item.Status;

        // Status update
        if (request.Status.HasValue)
        {
          item.SetStatus(request.Status.Value);
        }

        item.UpdateTimestamps();

        // Update inventory if status changes (and new status was provided)
        if (request.Status.HasValue && request.Status.Value != oldStatus)
        {
          Stock? stock = await context.Stocks.SingleOrDefaultAsync(
            s => s.Id == item.StockId,
            ct
          );

          if (stock == null)
          {
            await transaction.RollbackAsync(ct);
            return new ResponseItemDTO(HttpStatusCode.NotFound, null,
              $"Stock associated with item ID '{id}' not found.");
          }

          ItemStatus newStatus = request.Status.Value;

          // Decrement from the old status
          UpdateStockQuantity(stock, oldStatus, -1);

          // Increment to the new status, unless it's LOST or DONATED
          if (newStatus != ItemStatus.LOST && newStatus != ItemStatus.DONATED)
          {
            UpdateStockQuantity(stock, newStatus, 1);
          }
        }

        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        var responseItem = MapToResponseEntityItemDto(item);

        return new ResponseItemDTO(HttpStatusCode.OK, responseItem, "Item updated successfully.");
      }
      catch
      {
        await transaction.RollbackAsync(ct);
        // Log the exception details
        return new ResponseItemDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while updating the item.");
      }
    }

    /// <summary>
    /// Deletes an item from the database.
    /// </summary>
    public static async Task<ResponseItemDeleteDTO> DeleteItem(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
    {
      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        Item? item = await context.Items.SingleOrDefaultAsync(
          i => i.Id == id,
          ct
        );

        if (item == null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseItemDeleteDTO(HttpStatusCode.NotFound, null, $"Item with ID '{id}' not found.");
        }

        if (item.Status is ItemStatus.AVAILABLE or ItemStatus.MAINTENANCE or ItemStatus.UNAVAILABLE)
        {
          Stock? stock = await context.Stocks.SingleOrDefaultAsync(s => s.Id == item.StockId, ct);
          if (stock != null)
          {
            UpdateStockQuantity(stock, item.Status, -1);
          }
          // If stock is null here, it's an inconsistency, but we might still proceed with item deletion
          // depending on business rules. A log would be appropriate.
        }

        context.Items.Remove(item);
        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        return new ResponseItemDeleteDTO(HttpStatusCode.OK, item.StockId, "Item deleted successfully.");
      }
      catch
      {
        await transaction.RollbackAsync(ct);
        return new ResponseItemDeleteDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while deleting the item.");
      }
    }

    /// <summary>
    /// Helper method to update stock quantities based on item status changes.
    /// </summary>
    private static void UpdateStockQuantity(Stock stock, ItemStatus status, int quantityChange)
    {
      switch (status)
      {
        case ItemStatus.AVAILABLE:
          stock.SetAvailableQtd(stock.AvailableQtd + quantityChange);
          break;
        case ItemStatus.MAINTENANCE:
          stock.SetMaintenanceQtd(stock.MaintenanceQtd + quantityChange);
          break;
        case ItemStatus.UNAVAILABLE:
          stock.SetBorrowedQtd(stock.BorrowedQtd + quantityChange);
          break;
        case ItemStatus.LOST:
        case ItemStatus.DONATED:
          break;
        default:
          throw new ArgumentOutOfRangeException(nameof(status), status, null);
      }
    }

    /// <summary>
    /// Maps an Item entity to a ResponseEntityItemDTO.
    /// </summary>
    private static ResponseEntityItemDTO MapToResponseEntityItemDto(Item item)
    {
      return new ResponseEntityItemDTO(
        item.Id,
        item.SeriaCode,
        item.Status.ToString(),
        item.StockId,
        item.CreatedAt
      );
    }
  }
}