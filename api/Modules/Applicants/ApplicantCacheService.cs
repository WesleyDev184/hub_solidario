using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Applicants;

public static class ApplicantCacheService
{
  public static class Keys
  {
    public const string AllApplicants = "applicants-all";
    public static string ApplicantById(Guid id) => $"applicant-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a applicants
  /// </summary>
  public static async Task InvalidateAllApplicantCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllApplicants, ct);
  }

  /// <summary>
  /// Invalida o cache de um applicant específico
  /// </summary>
  public static async Task InvalidateApplicantCache(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ApplicantById(applicantId), ct);
    await cache.RemoveByTagAsync("loans", ct);
    await InvalidateAllApplicantCaches(cache, ct);
  }

  public static async Task InvalidateApplicantCacheByDependent(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ApplicantById(applicantId), ct);
  }
}
