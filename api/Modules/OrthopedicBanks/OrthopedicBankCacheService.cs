using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankCacheService
{
  public static class Keys
  {
    public const string AllOrthopedicBanks = "orthopedic-banks-all";
    public static string OrthopedicBankById(Guid id) => $"orthopedic-bank-{id}";
    public static string OrthopedicBanksByCity(string city) => $"orthopedic-banks-city-{city}";
    public static string OrthopedicBanksByName(string name) => $"orthopedic-banks-name-{name}";
  }

  /// <summary>
  /// Invalida todos os caches relacionados a orthopedic banks
  /// </summary>
  public static async Task InvalidateAllOrthopedicBankCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
  }

  /// <summary>
  /// Invalida o cache de um orthopedic bank específico
  /// </summary>
  public static async Task InvalidateOrthopedicBankCache(HybridCache cache, Guid orthopedicBankId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.OrthopedicBankById(orthopedicBankId), ct);
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a uma cidade específica
  /// </summary>
  public static async Task InvalidateCityOrthopedicBankCaches(HybridCache cache, string city, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.OrthopedicBanksByCity(city), ct);
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
  }

  /// <summary>
  /// Invalida caches relacionados a um nome específico
  /// </summary>
  public static async Task InvalidateNameOrthopedicBankCaches(HybridCache cache, string name, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.OrthopedicBanksByName(name), ct);
    await cache.RemoveAsync(Keys.AllOrthopedicBanks, ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um orthopedic bank é criado
  /// </summary>
  public static async Task InvalidateOnOrthopedicBankCreated(HybridCache cache, string? city = null, string? name = null, CancellationToken ct = default)
  {
    await InvalidateAllOrthopedicBankCaches(cache, ct);
    if (!string.IsNullOrEmpty(city))
    {
      await InvalidateCityOrthopedicBankCaches(cache, city, ct);
    }
    if (!string.IsNullOrEmpty(name))
    {
      await InvalidateNameOrthopedicBankCaches(cache, name, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um orthopedic bank é atualizado
  /// </summary>
  public static async Task InvalidateOnOrthopedicBankUpdated(HybridCache cache, Guid orthopedicBankId, string? oldCity = null, string? newCity = null, string? oldName = null, string? newName = null, CancellationToken ct = default)
  {
    await InvalidateOrthopedicBankCache(cache, orthopedicBankId, ct);
    if (!string.IsNullOrEmpty(oldCity))
    {
      await InvalidateCityOrthopedicBankCaches(cache, oldCity, ct);
    }
    if (!string.IsNullOrEmpty(newCity) && newCity != oldCity)
    {
      await InvalidateCityOrthopedicBankCaches(cache, newCity, ct);
    }
    if (!string.IsNullOrEmpty(oldName))
    {
      await InvalidateNameOrthopedicBankCaches(cache, oldName, ct);
    }
    if (!string.IsNullOrEmpty(newName) && newName != oldName)
    {
      await InvalidateNameOrthopedicBankCaches(cache, newName, ct);
    }
  }

  /// <summary>
  /// Invalida todos os caches relacionados quando um orthopedic bank é deletado
  /// </summary>
  public static async Task InvalidateOnOrthopedicBankDeleted(HybridCache cache, Guid orthopedicBankId, CancellationToken ct = default)
  {
    await InvalidateOrthopedicBankCache(cache, orthopedicBankId, ct);
  }
}
