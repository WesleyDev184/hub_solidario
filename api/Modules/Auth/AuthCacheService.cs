using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Auth;

public static class AuthCacheService
{
  public static class Keys
  {
    public const string AllUsers = "users-all";
    public static string UserById(Guid id) => $"user-{id}";
    public static string UsersByHub(Guid hubId) => $"users-hub-{hubId}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a usuários
  /// </summary>
  public static async Task InvalidateAllUserCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllUsers, ct);
  }

  /// <summary>
  /// Invalida o cache de um usuário específico
  /// </summary>
  public static async Task InvalidateUserCache(HybridCache cache, Guid userId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.UserById(userId), ct);

    await cache.RemoveAsync(Keys.AllUsers, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateHubUserCaches(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.UsersByHub(hubId), ct);
    await cache.RemoveAsync(Keys.AllUsers, ct);
  }
}
