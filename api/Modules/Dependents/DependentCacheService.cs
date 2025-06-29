using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Dependents;

public static class DependentCacheService
{
  public static class Keys
  {
    public const string AllDependents = "dependents-all";
    public static string DependentById(Guid id) => $"dependent-{id}";
    public static string DependentsByApplicant(Guid applicantId) => $"dependents-applicant-{applicantId}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a dependents
  /// </summary>
  public static async Task InvalidateAllDependentCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllDependents, ct);
  }

  /// <summary>
  /// Invalida o cache de um dependent específico
  /// </summary>
  public static async Task InvalidateDependentCache(HybridCache cache, Guid dependentId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DependentById(dependentId), ct);
    await cache.RemoveAsync(Keys.AllDependents, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um applicant específico
  /// </summary>
  public static async Task InvalidateApplicantDependentCaches(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DependentsByApplicant(applicantId), ct);
    await cache.RemoveAsync(Keys.AllDependents, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um dependent é criado
  /// </summary>
  public static async Task InvalidateOnDependentCreated(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await InvalidateAllDependentCaches(cache, ct);
    await InvalidateApplicantDependentCaches(cache, applicantId, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um dependent é atualizado
  /// </summary>
  public static async Task InvalidateOnDependentUpdated(HybridCache cache, Guid dependentId, Guid? applicantId = null, CancellationToken ct = default)
  {
    await InvalidateDependentCache(cache, dependentId, ct);
    if (applicantId.HasValue)
    {
      await InvalidateApplicantDependentCaches(cache, applicantId.Value, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um dependent é deletado
  /// </summary>
  public static async Task InvalidateOnDependentDeleted(HybridCache cache, Guid dependentId, CancellationToken ct = default)
  {
    await InvalidateDependentCache(cache, dependentId, ct);
  }
}
