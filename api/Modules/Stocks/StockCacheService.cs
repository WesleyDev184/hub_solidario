using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Stocks;

public static class StockCacheService
{
  public static class Keys
  {
    public const string AllStocks = "stocks-all";
    public static string StockById(Guid id) => $"stock-{id}";
    public static string StocksByHub(Guid hubId) => $"stocks-hub-{hubId}";
    public static string StocksByStatus(string status) => $"stocks-status-{status}";
  }

  public static class Tags
  {
    public const string Stocks = "stocks";
    public const string Items = "items";
    public const string Loans = "loans";
    public const string Hubs = "hubs";
    public static string StocksByHub(Guid hubId) => $"stocks-hub-{hubId}";
    public static string StocksByStatus(string status) => $"stocks-status-{status}";
  }

  public static class CacheOptions
  {
    public static readonly HybridCacheEntryOptions Default = new()
    {
      Expiration = TimeSpan.FromMinutes(30),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };

    public static readonly HybridCacheEntryOptions LongTerm = new()
    {
      Expiration = TimeSpan.FromHours(4),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };

    public static readonly HybridCacheEntryOptions Short = new()
    {
      Expiration = TimeSpan.FromMinutes(10),
      LocalCacheExpiration = TimeSpan.FromMinutes(2)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a stocks (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllStockCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Stocks, ct);
    await cache.RemoveAsync(Keys.AllStocks, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um stock específico e dados relacionados
  /// </summary>
  public static async Task InvalidateStockCache(HybridCache cache, Guid stockId, Guid? hubId = null, string? status = null, CancellationToken ct = default)
  {
    // Remove cache específico do stock
    await cache.RemoveAsync(Keys.StockById(stockId), ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Items, ct);
    await cache.RemoveByTagAsync(Tags.Loans, ct);
    await cache.RemoveByTagAsync(Tags.Stocks, ct);

    // Se hubId foi fornecido, remove cache específico do hub
    if (hubId.HasValue)
    {
      await cache.RemoveAsync(Keys.StocksByHub(hubId.Value), ct);
      await cache.RemoveByTagAsync(Tags.StocksByHub(hubId.Value), ct);
    }

    // Se status foi fornecido, remove cache específico do status
    if (!string.IsNullOrEmpty(status))
    {
      await cache.RemoveAsync(Keys.StocksByStatus(status), ct);
      await cache.RemoveByTagAsync(Tags.StocksByStatus(status), ct);
    }
  }

  /// <summary>
  /// Invalida caches relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateHubStockCaches(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StocksByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.StocksByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.Stocks, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um status específico
  /// </summary>
  public static async Task InvalidateStockCacheByStatus(HybridCache cache, string status, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.StocksByStatus(status), ct);
    await cache.RemoveByTagAsync(Tags.StocksByStatus(status), ct);
    await cache.RemoveByTagAsync(Tags.Stocks, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateStockCacheByHubs(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateHubStockCaches(cache, hubId, ct));
    await Task.WhenAll(tasks);
  }

  /// <summary>
  /// Invalida múltiplos caches de status (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateStockCacheByStatuses(HybridCache cache, IEnumerable<string> statuses, CancellationToken ct = default)
  {
    var tasks = statuses.Select(status => InvalidateStockCacheByStatus(cache, status, ct));
    await Task.WhenAll(tasks);
  }
}
