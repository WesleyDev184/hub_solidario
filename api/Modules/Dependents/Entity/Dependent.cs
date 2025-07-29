using api.Modules.Applicants.Entity;

namespace api.Modules.Dependents.Entity;

public class Dependent
{
  public Guid Id { get; init; }
  public string Name { get; private set; }
  public string CPF { get; private set; }
  public string Email { get; private set; }
  public string PhoneNumber { get; private set; }
  public string Address { get; private set; }

  public Guid ApplicantId { get; init; }
  public string? ProfileImageUrl { get; private set; }
  public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // Propriedade de navegação
  public Applicant? Applicant { get; init; }

  public Dependent(string name, string cpf, string email, string phoneNumber, string address, Guid applicantId, string? profileImageUrl = null)
  {
    Id = Guid.NewGuid();
    Name = name;
    CPF = cpf;
    Email = email;
    PhoneNumber = phoneNumber;
    Address = address;
    ApplicantId = applicantId;
    ProfileImageUrl = profileImageUrl;
  }

  private Dependent()
  {
    Id = Guid.NewGuid();
    Name = string.Empty;
    CPF = string.Empty;
    Email = string.Empty;
    PhoneNumber = string.Empty;
    Address = string.Empty;
    ProfileImageUrl = null;
  }

  public void SetProfileImageUrl(string? url)
  {
    ProfileImageUrl = url;
  }

  public void SetName(string name)
  {
    Name = name;
  }

  public void SetCPF(string cpf)
  {
    CPF = cpf;
  }

  public void SetEmail(string email)
  {
    Email = email;
  }

  public void SetPhoneNumber(string phoneNumber)
  {
    PhoneNumber = phoneNumber;
  }

  public void SetAddress(string address)
  {
    Address = address;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}