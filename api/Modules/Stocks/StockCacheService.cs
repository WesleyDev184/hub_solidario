using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Stocks;

public static class StockCacheService
{
  public static class Keys
  {
    public const string AllStocks = "stocks-all";
    public static string StockById(Guid id) => $"stock-{id}";
    public static string StocksByHub(Guid hubId) => $"stocks-hub-{hubId}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a stocks
  /// </summary>
  public static async Task InvalidateAllStockCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllStocks, ct);
  }

  /// <summary>
  /// Invalida o cache de um stock específico
  /// </summary>
  public static async Task InvalidateStockCache(HybridCache cache, Guid stockId, Guid? hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StockById(stockId), ct);
    await InvalidateAllStockCaches(cache, ct);

    if (hubId.HasValue)
      await InvalidateHubStockCaches(cache, hubId.Value, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um banco ortopédico específico
  /// </summary>
  public static async Task InvalidateHubStockCaches(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StocksByHub(hubId), ct);
  }
}
