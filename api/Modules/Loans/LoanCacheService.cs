using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Loans;

public static class LoanCacheService
{
  public static class Keys
  {
    public const string AllLoans = "loans-all";
    public static string LoanById(Guid id) => $"loan-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a loans
  /// </summary>
  public static async Task InvalidateAllLoanCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida o cache de um loan específico
  /// </summary>
  public static async Task InvalidateLoanCache(HybridCache cache, Guid loanId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoanById(loanId), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }
}
