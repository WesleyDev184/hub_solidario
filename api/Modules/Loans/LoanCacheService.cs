using api.Modules.Items;
using api.Modules.Stocks;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Loans;

public static class LoanCacheService
{
  public static class Keys
  {
    public const string AllLoans = "loans-all";
    public static string LoanById(Guid id) => $"loan-{id}";
    public static string LoansByHubId(Guid hubId) => $"loans-hub-{hubId}";
  }

  public static class Tags
  {
    public const string Loans = "loans";
    public const string Stocks = "stocks";
    public static string LoansByHub(Guid hubId) => $"loans-hub-{hubId}";
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
      Expiration = TimeSpan.FromDays(2),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a loans (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllLoanCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Loans, ct);
    await cache.RemoveAsync(Keys.AllLoans, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um loan específico e dados relacionados
  /// </summary>
  public static async Task InvalidateLoanCache(HybridCache cache, Guid loanId, Guid? stockId, Guid? hubId = null, CancellationToken ct = default)
  {
    // Remove cache específico do loan
    await cache.RemoveAsync(Keys.LoanById(loanId), ct);

    // Remove caches relacionados a stocks
    await cache.RemoveByTagAsync(Tags.Stocks, ct);

    // Remove cache geral de loans
    await cache.RemoveByTagAsync(Tags.Loans, ct);

    // Se hubId foi fornecido, remove cache específico do hub
    if (hubId.HasValue)
    {
      await cache.RemoveAsync(Keys.LoansByHubId(hubId.Value), ct);
      await cache.RemoveByTagAsync(Tags.LoansByHub(hubId.Value), ct);
    }

    // Remove caches relacionados ao stock específico
    if (stockId.HasValue)
    {
      await cache.RemoveByTagAsync(ItemCacheService.Keys.ItemStockById(stockId.Value), ct);
      await StockCacheService.InvalidateStockCache(cache, stockId.Value, null, null, ct);
    }
  }

  /// <summary>
  /// Invalida caches de loans relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateLoanCacheByHub(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.LoansByHubId(hubId), ct);
    await cache.RemoveByTagAsync(Tags.LoansByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.Loans, ct); // Garante que a listagem geral seja atualizada
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateLoanCacheByHubs(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateLoanCacheByHub(cache, hubId, ct));
    await Task.WhenAll(tasks);
  }
}
