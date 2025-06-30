using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Stocks;

public static class StockCacheService
{
  public static class Keys
  {
    public const string AllStocks = "stocks-all";
    public static string StockById(Guid id) => $"stock-{id}";
    public static string StocksByOrthopedicBank(Guid orthopedicBankId) => $"stocks-orthopedic-bank-{orthopedicBankId}";
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
  public static async Task InvalidateStockCache(HybridCache cache, Guid stockId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StockById(stockId), ct);
    await cache.RemoveAsync(Keys.AllStocks, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um banco ortopédico específico
  /// </summary>
  public static async Task InvalidateOrthopedicBankStockCaches(HybridCache cache, Guid orthopedicBankId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StocksByOrthopedicBank(orthopedicBankId), ct);
    await cache.RemoveAsync(Keys.AllStocks, ct);
  }
}
