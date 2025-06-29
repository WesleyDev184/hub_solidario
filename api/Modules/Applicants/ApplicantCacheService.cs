using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Applicants;

public static class ApplicantCacheService
{
  public static class Keys
  {
    public const string AllApplicants = "applicants-all";
    public static string ApplicantById(Guid id) => $"applicant-{id}";
    public static string ApplicantsByEmail(string email) => $"applicants-email-{email}";
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
    await cache.RemoveAsync(Keys.AllApplicants, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um email específico
  /// </summary>
  public static async Task InvalidateApplicantEmailCache(HybridCache cache, string email, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ApplicantsByEmail(email), ct);
    await cache.RemoveAsync(Keys.AllApplicants, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um applicant é criado
  /// </summary>
  public static async Task InvalidateOnApplicantCreated(HybridCache cache, string? email = null, CancellationToken ct = default)
  {
    await InvalidateAllApplicantCaches(cache, ct);
    if (!string.IsNullOrEmpty(email))
    {
      await InvalidateApplicantEmailCache(cache, email, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um applicant é atualizado
  /// </summary>
  public static async Task InvalidateOnApplicantUpdated(HybridCache cache, Guid applicantId, string? email = null, CancellationToken ct = default)
  {
    await InvalidateApplicantCache(cache, applicantId, ct);
    if (!string.IsNullOrEmpty(email))
    {
      await InvalidateApplicantEmailCache(cache, email, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um applicant é deletado
  /// </summary>
  public static async Task InvalidateOnApplicantDeleted(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await InvalidateApplicantCache(cache, applicantId, ct);
  }
}
