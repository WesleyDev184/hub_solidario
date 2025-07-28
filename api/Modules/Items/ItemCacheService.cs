using api.Modules.Stocks;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Items;

public static class ItemCacheService
{
  public static class Keys
  {
    public const string AllItems = "items-all";
    public static string ItemById(Guid id) => $"item-{id}";
    public static string ItemStockById(Guid id) => $"item-stock-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a items (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllItemCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um item específico e dados relacionados
  /// </summary>
  public static async Task InvalidateItemCache(HybridCache cache, Guid itemId, Guid? StockId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemById(itemId), ct);
    await cache.RemoveByTagAsync("loans", ct);
    await cache.RemoveByTagAsync("stocks", ct);
    await InvalidateAllItemCaches(cache, ct); // Garante que a listagem seja atualizada

    if (StockId.HasValue)
    {
      await cache.RemoveAsync(StockCacheService.Keys.StockById(StockId.Value), ct);
      await cache.RemoveAsync(Keys.ItemStockById(StockId.Value), ct);
    }
  }
}
