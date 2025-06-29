using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Items;

public static class ItemCacheService
{
  public static class Keys
  {
    public const string AllItems = "items-all";
    public static string ItemById(Guid id) => $"item-{id}";
    public static string ItemsByStock(Guid stockId) => $"items-stock-{stockId}";
    public static string ItemsByStatus(string status) => $"items-status-{status}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a items
  /// </summary>
  public static async Task InvalidateAllItemCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida o cache de um item específico
  /// </summary>
  public static async Task InvalidateItemCache(HybridCache cache, Guid itemId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemById(itemId), ct);
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um stock específico
  /// </summary>
  public static async Task InvalidateStockItemCaches(HybridCache cache, Guid stockId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemsByStock(stockId), ct);
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um status específico
  /// </summary>
  public static async Task InvalidateStatusItemCaches(HybridCache cache, string status, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemsByStatus(status), ct);
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um item é criado
  /// </summary>
  public static async Task InvalidateOnItemCreated(HybridCache cache, Guid stockId, string? status = null, CancellationToken ct = default)
  {
    await InvalidateAllItemCaches(cache, ct);
    await InvalidateStockItemCaches(cache, stockId, ct);
    if (!string.IsNullOrEmpty(status))
    {
      await InvalidateStatusItemCaches(cache, status, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um item é atualizado
  /// </summary>
  public static async Task InvalidateOnItemUpdated(HybridCache cache, Guid itemId, Guid? stockId = null, string? oldStatus = null, string? newStatus = null, CancellationToken ct = default)
  {
    await InvalidateItemCache(cache, itemId, ct);
    if (stockId.HasValue)
    {
      await InvalidateStockItemCaches(cache, stockId.Value, ct);
    }
    if (!string.IsNullOrEmpty(oldStatus))
    {
      await InvalidateStatusItemCaches(cache, oldStatus, ct);
    }
    if (!string.IsNullOrEmpty(newStatus) && newStatus != oldStatus)
    {
      await InvalidateStatusItemCaches(cache, newStatus, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um item é deletado
  /// </summary>
  public static async Task InvalidateOnItemDeleted(HybridCache cache, Guid itemId, CancellationToken ct = default)
  {
    await InvalidateItemCache(cache, itemId, ct);
  }
}
