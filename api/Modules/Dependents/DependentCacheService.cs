using api.Modules.Applicants;
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

  public static class Tags
  {
    public const string Dependents = "dependents";
    public const string Applicants = "applicants";
    public static string DependentsByApplicant(Guid applicantId) => $"dependents-applicant-{applicantId}";
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
      Expiration = TimeSpan.FromHours(8),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a dependents (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllDependentCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Dependents, ct);
    await cache.RemoveAsync(Keys.AllDependents, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um dependent específico e dados relacionados
  /// </summary>
  public static async Task InvalidateDependentCache(HybridCache cache, Guid dependentId, Guid? applicantId = null, CancellationToken ct = default)
  {
    // Remove cache específico do dependent
    await cache.RemoveAsync(Keys.DependentById(dependentId), ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Dependents, ct);

    // Se applicantId foi fornecido, remove caches relacionados
    if (applicantId.HasValue)
    {
      await cache.RemoveAsync(Keys.DependentsByApplicant(applicantId.Value), ct);
      await cache.RemoveByTagAsync(Tags.DependentsByApplicant(applicantId.Value), ct);
      await ApplicantCacheService.InvalidateApplicantCache(cache, applicantId.Value, null, ct);
    }
  }

  /// <summary>
  /// Invalida caches de dependents relacionados a um applicant específico
  /// </summary>
  public static async Task InvalidateDependentCacheByApplicant(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DependentsByApplicant(applicantId), ct);
    await cache.RemoveByTagAsync(Tags.DependentsByApplicant(applicantId), ct);
    await cache.RemoveByTagAsync(Tags.Dependents, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de applicants (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateDependentCacheByApplicants(HybridCache cache, IEnumerable<Guid> applicantIds, CancellationToken ct = default)
  {
    var tasks = applicantIds.Select(applicantId => InvalidateDependentCacheByApplicant(cache, applicantId, ct));
    await Task.WhenAll(tasks);
  }
}
