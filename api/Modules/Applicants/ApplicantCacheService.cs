using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Applicants;

public static class ApplicantCacheService
{
  public static class Keys
  {
    public const string AllApplicants = "applicants-all";
    public static string ApplicantById(Guid id) => $"applicant-{id}";
    public static string ApplicantsByHub(Guid hubId) => $"applicants-hub-{hubId}";
  }

  public static class Tags
  {
    public const string Applicants = "applicants";
    public const string Loans = "loans";
    public const string Dependents = "dependents";
    public static string ApplicantsByHub(Guid hubId) => $"applicants-hub-{hubId}";
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
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a applicants (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllApplicantCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Applicants, ct);
    await cache.RemoveAsync(Keys.AllApplicants, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um applicant específico e dados relacionados
  /// </summary>
  public static async Task InvalidateApplicantCache(HybridCache cache, Guid applicantId, Guid? hubId = null, CancellationToken ct = default)
  {
    // Remove cache específico do applicant
    await cache.RemoveAsync(Keys.ApplicantById(applicantId), ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Loans, ct);
    await cache.RemoveByTagAsync(Tags.Dependents, ct);
    await cache.RemoveByTagAsync(Tags.Applicants, ct);

    // Se hubId foi fornecido, remove cache específico do hub
    if (hubId.HasValue)
    {
      await cache.RemoveAsync(Keys.ApplicantsByHub(hubId.Value), ct);
      await cache.RemoveByTagAsync(Tags.ApplicantsByHub(hubId.Value), ct);
    }
  }

  /// <summary>
  /// Invalida caches de applicants relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateApplicantCacheByHub(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ApplicantsByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.ApplicantsByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.Applicants, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateApplicantCacheByHubs(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateApplicantCacheByHub(cache, hubId, ct));
    await Task.WhenAll(tasks);
  }
}
