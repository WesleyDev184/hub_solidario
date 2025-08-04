namespace api.Modules.Documents;

using Dto;
using Microsoft.Extensions.Caching.Hybrid;

public static class DocumentCacheService
{
  private const string CacheKeyPrefix = "document:";
  private const string ListCacheKeyPrefix = "documents:applicant:";
  private const string DependentListCacheKeyPrefix = "documents:dependent:";

  // Invalidar cache de um documento específico
  public static async Task InvalidateDocumentCache(this HybridCache cache, Guid documentId)
  {
    await cache.RemoveAsync($"{CacheKeyPrefix}{documentId}");
  }

  // Invalidar cache de lista de documentos por applicant
  public static async Task InvalidateDocumentsByApplicantCache(this HybridCache cache, Guid applicantId)
  {
    await cache.RemoveAsync($"{ListCacheKeyPrefix}{applicantId}");
  }

  // Invalidar cache de lista de documentos por dependent
  public static async Task InvalidateDocumentsByDependentCache(this HybridCache cache, Guid dependentId)
  {
    await cache.RemoveAsync($"{DependentListCacheKeyPrefix}{dependentId}");
  }

  // Invalidar todos os caches relacionados ao documento
  public static async Task InvalidateAllDocumentCaches(this HybridCache cache, Guid documentId, Guid applicantId, Guid? dependentId = null)
  {
    await cache.InvalidateDocumentCache(documentId);
    await cache.InvalidateDocumentsByApplicantCache(applicantId);

    if (dependentId.HasValue)
    {
      await cache.InvalidateDocumentsByDependentCache(dependentId.Value);
    }
  }

  // Buscar documento no cache ou executar função de fallback
  public static async Task<ResponseControllerDocumentsDTO> GetOrSetDocumentCache(
    this HybridCache cache,
    Guid documentId,
    Func<CancellationToken, ValueTask<ResponseControllerDocumentsDTO>> factory,
    TimeSpan? expiry = null,
    CancellationToken ct = default)
  {
    return await cache.GetOrCreateAsync<ResponseControllerDocumentsDTO>(
      $"{CacheKeyPrefix}{documentId}",
      factory,
      options: new HybridCacheEntryOptions
      {
        Expiration = expiry ?? TimeSpan.FromMinutes(30),
        LocalCacheExpiration = TimeSpan.FromMinutes(5)
      },
      cancellationToken: ct
    );
  }

  // Buscar lista de documentos por applicant no cache ou executar função de fallback
  public static async Task<ResponseDocumentsDTO> GetOrSetDocumentsByApplicantCache(
    this HybridCache cache,
    Guid applicantId,
    Func<CancellationToken, ValueTask<ResponseDocumentsDTO>> factory,
    TimeSpan? expiry = null,
    CancellationToken ct = default)
  {
    return await cache.GetOrCreateAsync<ResponseDocumentsDTO>(
      $"{ListCacheKeyPrefix}{applicantId}",
      factory,
      options: new HybridCacheEntryOptions
      {
        Expiration = expiry ?? TimeSpan.FromMinutes(15),
        LocalCacheExpiration = TimeSpan.FromMinutes(3)
      },
      cancellationToken: ct
    );
  }

  // Buscar lista de documentos por dependent no cache ou executar função de fallback
  public static async Task<ResponseDocumentsDTO> GetOrSetDocumentsByDependentCache(
    this HybridCache cache,
    Guid dependentId,
    Func<CancellationToken, ValueTask<ResponseDocumentsDTO>> factory,
    TimeSpan? expiry = null,
    CancellationToken ct = default)
  {
    return await cache.GetOrCreateAsync<ResponseDocumentsDTO>(
      $"{DependentListCacheKeyPrefix}{dependentId}",
      factory,
      options: new HybridCacheEntryOptions
      {
        Expiration = expiry ?? TimeSpan.FromMinutes(15),
        LocalCacheExpiration = TimeSpan.FromMinutes(3)
      },
      cancellationToken: ct
    );
  }
}
