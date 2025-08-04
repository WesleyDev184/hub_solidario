using api.Modules.Applicants.Entity;
using api.Modules.Dependents.Entity;

namespace api.Modules.Documents.Entity;

public class Document
{
  public Guid Id { get; init; }
  public string OriginalFileName { get; private set; }
  public string StorageUrl { get; private set; }
  public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // Relacionamento obrigatório com Applicant
  public Guid ApplicantId { get; private set; }
  public Applicant Applicant { get; private set; } = null!;

  // Relacionamento opcional com Dependent
  public Guid? DependentId { get; private set; }
  public Dependent? Dependent { get; private set; }

  public Document(string originalFileName, string storageUrl, Guid applicantId, Guid? dependentId = null)
  {
    Id = Guid.NewGuid();
    OriginalFileName = originalFileName;
    StorageUrl = storageUrl;
    ApplicantId = applicantId;
    DependentId = dependentId;
  }

  private Document()
  {
    Id = Guid.NewGuid();
    OriginalFileName = string.Empty;
    StorageUrl = string.Empty;
    ApplicantId = Guid.Empty;
    DependentId = null;
  }

  public void SetOriginalFileName(string originalFileName)
  {
    OriginalFileName = originalFileName;
  }

  public void SetStorageUrl(string storageUrl)
  {
    StorageUrl = storageUrl;
  }

  public void SetDependentId(Guid? dependentId)
  {
    DependentId = dependentId;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}
