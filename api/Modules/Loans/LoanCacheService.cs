using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Loans;

public static class LoanCacheService
{
  public static class Keys
  {
    public const string AllLoans = "loans-all";
    public static string LoanById(Guid id) => $"loan-{id}";
    public static string LoansByApplicant(Guid applicantId) => $"loans-applicant-{applicantId}";
    public static string LoansByItem(Guid itemId) => $"loans-item-{itemId}";
    public static string LoansByStatus(string status) => $"loans-status-{status}";
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

  /// <summary>
  /// Invalida caches relacionados a um applicant específico
  /// </summary>
  public static async Task InvalidateApplicantLoanCaches(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoansByApplicant(applicantId), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um item específico
  /// </summary>
  public static async Task InvalidateItemLoanCaches(HybridCache cache, Guid itemId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoansByItem(itemId), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um status específico
  /// </summary>
  public static async Task InvalidateStatusLoanCaches(HybridCache cache, string status, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoansByStatus(status), ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um loan é criado
  /// </summary>
  public static async Task InvalidateOnLoanCreated(HybridCache cache, Guid applicantId, Guid itemId, string? status = null, CancellationToken ct = default)
  {
    await InvalidateAllLoanCaches(cache, ct);
    await InvalidateApplicantLoanCaches(cache, applicantId, ct);
    await InvalidateItemLoanCaches(cache, itemId, ct);
    if (!string.IsNullOrEmpty(status))
    {
      await InvalidateStatusLoanCaches(cache, status, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um loan é atualizado
  /// </summary>
  public static async Task InvalidateOnLoanUpdated(HybridCache cache, Guid loanId, Guid? applicantId = null, Guid? itemId = null, string? oldStatus = null, string? newStatus = null, CancellationToken ct = default)
  {
    await InvalidateLoanCache(cache, loanId, ct);
    if (applicantId.HasValue)
    {
      await InvalidateApplicantLoanCaches(cache, applicantId.Value, ct);
    }
    if (itemId.HasValue)
    {
      await InvalidateItemLoanCaches(cache, itemId.Value, ct);
    }
    if (!string.IsNullOrEmpty(oldStatus))
    {
      await InvalidateStatusLoanCaches(cache, oldStatus, ct);
    }
    if (!string.IsNullOrEmpty(newStatus) && newStatus != oldStatus)
    {
      await InvalidateStatusLoanCaches(cache, newStatus, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um loan é deletado
  /// </summary>
  public static async Task InvalidateOnLoanDeleted(HybridCache cache, Guid loanId, CancellationToken ct = default)
  {
    await InvalidateLoanCache(cache, loanId, ct);
  }
}
