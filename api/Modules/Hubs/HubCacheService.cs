using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Hubs;

public static class HubCacheService
{
  public static class Keys
  {
    public const string AllHubs = "hubs-all";
    public static string HubById(Guid id) => $"hub-{id}";
    public static string HubsByRegion(string region) => $"hubs-region-{region}";
  }

  public static class Tags
  {
    public const string Hubs = "hubs";
    public const string Users = "users";
    public const string Stocks = "stocks";
    public const string Loans = "loans";
    public const string Applicants = "applicants";
    public static string HubsByRegion(string region) => $"hubs-region-{region}";
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
      Expiration = TimeSpan.FromDays(1),
      LocalCacheExpiration = TimeSpan.FromMinutes(10)
    };

    public static readonly HybridCacheEntryOptions VeryLongTerm = new()
    {
      Expiration = TimeSpan.FromDays(7),
      LocalCacheExpiration = TimeSpan.FromMinutes(15)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a hubs (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllHubCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Hubs, ct);
    await cache.RemoveAsync(Keys.AllHubs, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um hub específico e dados relacionados
  /// </summary>
  public static async Task InvalidateHubCache(HybridCache cache, Guid hubId, string? region = null, CancellationToken ct = default)
  {
    // Remove cache específico do hub
    await cache.RemoveAsync(Keys.HubById(hubId), ct);

    // Remove caches relacionados a entidades do hub
    await cache.RemoveByTagAsync($"users-hub-{hubId}", ct);
    await cache.RemoveByTagAsync($"stocks-hub-{hubId}", ct);
    await cache.RemoveByTagAsync($"loans-hub-{hubId}", ct);
    await cache.RemoveByTagAsync($"applicants-hub-{hubId}", ct);

    // Remove cache geral de hubs
    await cache.RemoveByTagAsync(Tags.Hubs, ct);

    // Se região foi fornecida, remove cache específico da região
    if (!string.IsNullOrEmpty(region))
    {
      await cache.RemoveAsync(Keys.HubsByRegion(region), ct);
      await cache.RemoveByTagAsync(Tags.HubsByRegion(region), ct);
    }
  }

  /// <summary>
  /// Invalida caches de hubs relacionados a uma região específica
  /// </summary>
  public static async Task InvalidateHubCacheByRegion(HybridCache cache, string region, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.HubsByRegion(region), ct);
    await cache.RemoveByTagAsync(Tags.HubsByRegion(region), ct);
    await cache.RemoveByTagAsync(Tags.Hubs, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de regiões (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateHubCacheByRegions(HybridCache cache, IEnumerable<string> regions, CancellationToken ct = default)
  {
    var tasks = regions.Select(region => InvalidateHubCacheByRegion(cache, region, ct));
    await Task.WhenAll(tasks);
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateHubCacheByIds(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateHubCache(cache, hubId, null, ct));
    await Task.WhenAll(tasks);
  }
}
