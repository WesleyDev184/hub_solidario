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

  public static class Tags
  {
    public const string Users = "users";
    public const string Hubs = "hubs";
    public static string UsersByHub(Guid hubId) => $"users-hub-{hubId}";
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
      Expiration = TimeSpan.FromHours(12),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };

    public static readonly HybridCacheEntryOptions Short = new()
    {
      Expiration = TimeSpan.FromMinutes(10),
      LocalCacheExpiration = TimeSpan.FromMinutes(2)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a usuários
  /// </summary>
  public static async Task InvalidateAllUserCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Users, ct);
    await cache.RemoveAsync(Keys.AllUsers, ct);
  }

  /// <summary>
  /// Invalida o cache de um usuário específico
  /// </summary>
  public static async Task InvalidateUserCache(HybridCache cache, Guid userId, Guid? hubId = null, CancellationToken ct = default)
  {
    // Remove cache específico do usuário
    await cache.RemoveAsync(Keys.UserById(userId), ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Users, ct);

    // Se hubId foi fornecido, remove cache específico do hub
    if (hubId.HasValue)
    {
      await cache.RemoveAsync(Keys.UsersByHub(hubId.Value), ct);
      await cache.RemoveByTagAsync(Tags.UsersByHub(hubId.Value), ct);
    }
  }

  /// <summary>
  /// Invalida caches relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateHubUserCaches(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.UsersByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.UsersByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.Users, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateUserCacheByHubs(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateHubUserCaches(cache, hubId, ct));
    await Task.WhenAll(tasks);
  }
}
