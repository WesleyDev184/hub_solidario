using Microsoft.Extensions.Caching.Hybrid;

namespace api.Auth;

public static class AuthCacheService
{
  public static class Keys
  {
    public const string AllUsers = "users-all";
    public static string UserById(Guid id) => $"user-{id}";
    public static string UsersByOrthopedicBank(Guid orthopedicBankId) => $"users-orthopedic-bank-{orthopedicBankId}";
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
  /// Invalida caches relacionados a um banco ortopédico específico
  /// </summary>
  public static async Task InvalidateOrthopedicBankUserCaches(HybridCache cache, Guid orthopedicBankId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.UsersByOrthopedicBank(orthopedicBankId), ct);
    await cache.RemoveAsync(Keys.AllUsers, ct);
  }
}
