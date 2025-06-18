using api.Modules.Applicants.Entity;
using api.Modules.Items.Entity;

namespace api.Modules.Loans.Entity;

public class Loan
{
  public Guid Id { get; init; }
  public Guid ApplicantId { get; init; }
  public Guid ResponsibleId { get; init; }
  public Guid ItemId { get; init; }
  public DateTime ReturnDate { get; set; }
  public string Reason { get; set; }
  public bool IsActive { get; set; } = true;
  public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // navegação
  public Applicant? Applicant { get; init; }
  public Item? Item { get; init; }

  public Loan(Guid applicantId, Guid responsibleId, Guid itemId, string reason)
  {
    Id = Guid.NewGuid();
    ApplicantId = applicantId;
    ResponsibleId = responsibleId;
    ItemId = itemId;
    Reason = reason;
    ReturnDate = DateTime.UtcNow.AddMonths(3);
  }

  private Loan()
  {
    Id = Guid.NewGuid();
    ApplicantId = Guid.Empty;
    ResponsibleId = Guid.Empty;
    ItemId = Guid.Empty;
    Reason = string.Empty;
    ReturnDate = DateTime.UtcNow.AddMonths(3);
  }

  public void SetReturnDate()
  {
    ReturnDate = DateTime.UtcNow.AddMonths(3);
  }

  public void SetReason(string reason)
  {
    Reason = reason;
  }

  public void SetIsActive(bool isActive)
  {
    IsActive = isActive;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }

}
