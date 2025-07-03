using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Loans;

public static class LoanCacheService
{
  public static class Keys
  {
    public const string AllLoans = "loans-all";
    public static string LoanById(Guid id) => $"loan-{id}";
    public static string LoanByApplicantId(Guid applicantId) => $"loan-applicant-{applicantId}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a loans
  /// </summary>
  public static async Task InvalidateAllLoanCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllLoans, ct);
    // Invalida todos os caches de loans usando a tag genérica
    await cache.RemoveByTagAsync("loans", ct);
  }

  /// <summary>
  /// Invalida o cache de um loan específico
  /// </summary>
  public static async Task InvalidateLoanCache(HybridCache cache, Guid loanId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoanById(loanId), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida caches de loans relacionados a um applicant específico
  /// </summary>
  public static async Task InvalidateLoanCacheByApplicant(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Keys.LoanByApplicantId(applicantId), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }
}
