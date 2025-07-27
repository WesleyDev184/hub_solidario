using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Hubs;

public static class HubCacheService
{
  public static class Keys
  {
    public const string AllHubs = "hubs-all";
    public static string HubById(Guid id) => $"hub-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a hubs
  /// </summary>
  public static async Task InvalidateAllHubCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllHubs, ct);
  }

  /// <summary>
  /// Invalida o cache de um hub específico
  /// </summary>
  public static async Task InvalidateHubCache(HybridCache cache, Guid HubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.HubById(HubId), ct);
    await cache.RemoveAsync(Keys.AllHubs, ct);
    await cache.RemoveByTagAsync($"user-{HubId}", ct);
  }
}
