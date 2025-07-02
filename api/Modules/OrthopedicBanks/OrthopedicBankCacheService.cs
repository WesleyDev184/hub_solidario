using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankCacheService
{
  public static class Keys
  {
    public const string AllOrthopedicBanks = "orthopedic-banks-all";
    public static string OrthopedicBankById(Guid id) => $"orthopedic-bank-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a orthopedic banks
  /// </summary>
  public static async Task InvalidateAllOrthopedicBankCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
  }

  /// <summary>
  /// Invalida o cache de um orthopedic bank específico
  /// </summary>
  public static async Task InvalidateOrthopedicBankCache(HybridCache cache, Guid orthopedicBankId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.OrthopedicBankById(orthopedicBankId), ct);
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
    await cache.RemoveByTagAsync($"user-{orthopedicBankId}", ct);
  }
}
