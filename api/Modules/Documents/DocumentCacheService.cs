using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Documents;

public static class DocumentCacheService
{
  public static class Keys
  {
    public const string AllDocuments = "documents-all";
    public static string DocumentById(Guid id) => $"document-{id}";
    public static string DocumentsByApplicant(Guid applicantId) => $"documents-applicant-{applicantId}";
    public static string DocumentsByDependent(Guid dependentId) => $"documents-dependent-{dependentId}";
  }

  public static class Tags
  {
    public const string Documents = "documents";
    public const string Applicants = "applicants";
    public const string Dependents = "dependents";
    public static string DocumentsByApplicant(Guid applicantId) => $"documents-applicant-{applicantId}";
    public static string DocumentsByDependent(Guid dependentId) => $"documents-dependent-{dependentId}";
  }

  public static class CacheOptions
  {
    public static readonly HybridCacheEntryOptions Default = new()
    {
      Expiration = TimeSpan.FromMinutes(30),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };

    public static readonly HybridCacheEntryOptions Short = new()
    {
      Expiration = TimeSpan.FromMinutes(15),
      LocalCacheExpiration = TimeSpan.FromMinutes(3)
    };

    public static readonly HybridCacheEntryOptions LongTerm = new()
    {
      Expiration = TimeSpan.FromHours(4),
      LocalCacheExpiration = TimeSpan.FromMinutes(5)
    };
  }

  /// <summary>
  /// Invalida todos os caches relacionados a documents (use apenas em operações em massa)
  /// </summary>
  public static async Task InvalidateAllDocumentCaches(HybridCache cache, CancellationToken ct = default)
  {
    await cache.RemoveByTagAsync(Tags.Documents, ct);
    await cache.RemoveAsync(Keys.AllDocuments, ct);
  }

  /// <summary>
  /// Invalida cache de um documento específico
  /// </summary>
  public static async Task InvalidateDocumentCache(HybridCache cache, Guid documentId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DocumentById(documentId), ct);
  }

  /// <summary>
  /// Invalida cache de lista de documentos por applicant
  /// </summary>
  public static async Task InvalidateDocumentsByApplicantCache(HybridCache cache, Guid applicantId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DocumentsByApplicant(applicantId), ct);
    await cache.RemoveByTagAsync(Tags.DocumentsByApplicant(applicantId), ct);
  }

  /// <summary>
  /// Invalida cache de lista de documentos por dependent
  /// </summary>
  public static async Task InvalidateDocumentsByDependentCache(HybridCache cache, Guid dependentId, CancellationToken ct = default)
  {
    await cache.RemoveAsync(Keys.DocumentsByDependent(dependentId), ct);
    await cache.RemoveByTagAsync(Tags.DocumentsByDependent(dependentId), ct);
  }

  /// <summary>
  /// Invalida todos os caches relacionados ao documento
  /// </summary>
  public static async Task InvalidateAllDocumentRelatedCaches(HybridCache cache, Guid documentId, Guid? applicantId = null, Guid? dependentId = null, CancellationToken ct = default)
  {
    // Remove cache específico do documento
    await InvalidateDocumentCache(cache, documentId, ct);

    // Remove caches relacionados
    await cache.RemoveByTagAsync(Tags.Documents, ct);

    // Se applicantId foi fornecido, remove caches relacionados
    if (applicantId.HasValue)
    {
      await InvalidateDocumentsByApplicantCache(cache, applicantId.Value, ct);
    }

    // Se dependentId foi fornecido, remove caches relacionados
    if (dependentId.HasValue)
    {
      await InvalidateDocumentsByDependentCache(cache, dependentId.Value, ct);
    }
  }

  /// <summary>
  /// Invalida múltiplos caches de applicants (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateDocumentCacheByApplicants(HybridCache cache, IEnumerable<Guid> applicantIds, CancellationToken ct = default)
  {
    var tasks = applicantIds.Select(applicantId => InvalidateDocumentsByApplicantCache(cache, applicantId, ct));
    await Task.WhenAll(tasks);
  }

  /// <summary>
  /// Invalida múltiplos caches de dependents (útil para operações em massa)
  /// </summary>
  public static async Task InvalidateDocumentCacheByDependents(HybridCache cache, IEnumerable<Guid> dependentIds, CancellationToken ct = default)
  {
    var tasks = dependentIds.Select(dependentId => InvalidateDocumentsByDependentCache(cache, dependentId, ct));
    await Task.WhenAll(tasks);
  }
}
