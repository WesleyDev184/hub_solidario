using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Items;

public static class ItemCacheService
{
  public static class Keys
  {
    public const string AllItems = "items-all";
    public static string ItemById(Guid id) => $"item-{id}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a items
  /// </summary>
  public static async Task InvalidateAllItemCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllItems, ct);
  }

  /// <summary>
  /// Invalida o cache de um item específico
  /// </summary>
  public static async Task InvalidateItemCache(HybridCache cache, Guid itemId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.ItemById(itemId), ct);
    await cache.RemoveAsync(Keys.AllItems, ct);
    await cache.RemoveByTagAsync("loans", ct);
    await cache.RemoveByTagAsync("stocks", ct);
  }
}
