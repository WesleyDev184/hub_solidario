using api.Modules.Applicants;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Dependents;

public static class DependentCacheService
{
  public static class Keys
  {
    public const string AllDependents = "dependents-all";
    public static string DependentById(Guid id) => $"dependent-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a dependents (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllDependentCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllDependents, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um dependent específico e dados relacionados
  /// </summary>
  public static async Task InvalidateDependentCache(HybridCache cache, Guid dependentId, Guid? applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DependentById(dependentId), ct);
    await InvalidateAllDependentCaches(cache, ct); // Garante que a listagem seja atualizada
    if (applicantId.HasValue)
    {
      await ApplicantCacheService.InvalidateApplicantCacheByDependent(cache, applicantId.Value, ct);
    }
  }

}
