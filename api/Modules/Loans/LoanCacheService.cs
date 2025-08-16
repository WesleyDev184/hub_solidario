using api.Modules.Items;
using api.Modules.Stocks;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Loans;

public static class LoanCacheService
{
  public static class Keys
  {
    public const string AllLoans = "loans-all";
    public const string AllLoansFullData = "loans-all-full-data";
    public static string LoanById(Guid id) => $"loan-{id}";
    public static string LoanByApplicantId(Guid applicantId) => $"loan-applicant-{applicantId}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a loans (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllLoanCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllLoans, ct);
    await cache.RemoveAsync(Keys.AllLoansFullData, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um loan específico e dados relacionados
  /// </summary>
  public static async Task InvalidateLoanCache(HybridCache cache, Guid loanId, Guid? stockId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoanById(loanId), ct);
    await cache.RemoveByTagAsync("stocks", ct);
    await InvalidateAllLoanCaches(cache, ct); // Garante que a listagem seja atualizada

    if (stockId.HasValue)
    {
      await cache.RemoveByTagAsync(ItemCacheService.Keys.ItemStockById(stockId.Value), ct);
      await StockCacheService.InvalidateStockCache(cache, stockId.Value, null, ct);
    }
  }

  /// <summary>
  /// Invalida caches de loans relacionados a um applicant específico
  /// </summary>
  public static async Task InvalidateLoanCacheByApplicant(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Keys.LoanByApplicantId(applicantId), ct);
    await InvalidateAllLoanCaches(cache, ct); // Garante que a listagem seja atualizada
  }
}
