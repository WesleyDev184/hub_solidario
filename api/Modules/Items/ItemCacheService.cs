using api.Modules.Stocks;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Items;

public static class ItemCacheService
{
  public static class Keys
  {
    public const string AllItems = "items-all";
    public static string ItemById(Guid id) => $"item-{id}";
    public static string ItemStockById(Guid id) => $"item-stock-{id}";
    public static string ItemsByCategory(string category) => $"items-category-{category}";
    public static string ItemsByHub(Guid hubId) => $"items-hub-{hubId}";
  }

  public static class Tags
  {
    public const string Items = "items";
    public const string Stocks = "stocks";
    public const string Loans = "loans";
    public static string ItemsByCategory(string category) => $"items-category-{category}";
    public static string ItemsByHub(Guid hubId) => $"items-hub-{hubId}";
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
      Expiration = TimeSpan.FromHours(6),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };

    public static readonly HybridCacheEntryOptions VeryLongTerm = new()
    {
      Expiration = TimeSpan.FromDays(1),
      LocalCacheExpiration = TimeSpan.FromMinutes(10)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a items (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllItemCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Items, ct);
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida apenas o cache de um item específico e dados relacionados
  /// </summary>
  public static async Task InvalidateItemCache(HybridCache cache, Guid itemId, Guid? stockId = null, string? category = null, Guid? hubId = null, CancellationToken ct = default)
  {
    // Remove cache específico do item
    await cache.RemoveAsync(Keys.ItemById(itemId), ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Loans, ct);
    await cache.RemoveByTagAsync(Tags.Stocks, ct);
    await cache.RemoveByTagAsync(Tags.Items, ct);

    // Se stockId foi fornecido, remove caches relacionados
    if (stockId.HasValue)
    {
      await cache.RemoveAsync(StockCacheService.Keys.StockById(stockId.Value), ct);
      await cache.RemoveAsync(Keys.ItemStockById(stockId.Value), ct);
      await StockCacheService.InvalidateStockCache(cache, stockId.Value, hubId, null, ct);
    }

    // Se categoria foi fornecida, remove cache específico da categoria
    if (!string.IsNullOrEmpty(category))
    {
      await cache.RemoveAsync(Keys.ItemsByCategory(category), ct);
      await cache.RemoveByTagAsync(Tags.ItemsByCategory(category), ct);
    }

    // Se hubId foi fornecido, remove cache específico do hub
    if (hubId.HasValue)
    {
      await cache.RemoveAsync(Keys.ItemsByHub(hubId.Value), ct);
      await cache.RemoveByTagAsync(Tags.ItemsByHub(hubId.Value), ct);
    }
  }

  /// <summary>
  /// Invalida caches de items relacionados a uma categoria específica
  /// </summary>
  public static async Task InvalidateItemCacheByCategory(HybridCache cache, string category, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemsByCategory(category), ct);
    await cache.RemoveByTagAsync(Tags.ItemsByCategory(category), ct);
    await cache.RemoveByTagAsync(Tags.Items, ct);
  }

  /// <summary>
  /// Invalida caches de items relacionados a um hub específico
  /// </summary>
  public static async Task InvalidateItemCacheByHub(HybridCache cache, Guid hubId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemsByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.ItemsByHub(hubId), ct);
    await cache.RemoveByTagAsync(Tags.Items, ct);
  }

  /// <summary>
  /// Invalida múltiplos caches de categorias (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateItemCacheByCategories(HybridCache cache, IEnumerable<string> categories, CancellationToken ct = default)
  {
    var tasks = categories.Select(category => InvalidateItemCacheByCategory(cache, category, ct));
    await Task.WhenAll(tasks);
  }

  /// <summary>
  /// Invalida múltiplos caches de hubs (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateItemCacheByHubs(HybridCache cache, IEnumerable<Guid> hubIds, CancellationToken ct = default)
  {
    var tasks = hubIds.Select(hubId => InvalidateItemCacheByHub(cache, hubId, ct));
    await Task.WhenAll(tasks);
  }
}
