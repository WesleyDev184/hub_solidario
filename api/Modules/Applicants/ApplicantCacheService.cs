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
  /// Invalida todos os caches relacionados a applicants (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllApplicantCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllApplicants, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um applicant específico e dados relacionados
  /// </summary>
  public static async Task InvalidateApplicantCache(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ApplicantById(applicantId), ct);
    await cache.RemoveByTagAsync("loans", ct);
    await InvalidateAllApplicantCaches(cache, ct); // Garante que a listagem seja atualizada
  }
}
