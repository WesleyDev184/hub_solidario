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
  /// Invalida todos os caches relacionados a hubs (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllHubCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllHubs, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um hub específico e dados relacionados
  /// </summary>
  public static async Task InvalidateHubCache(HybridCache cache, Guid HubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.HubById(HubId), ct);
    await cache.RemoveByTagAsync($"user-{HubId}", ct);
    await InvalidateAllHubCaches(cache, ct); // Garante que a listagem seja atualizada
  }
}
