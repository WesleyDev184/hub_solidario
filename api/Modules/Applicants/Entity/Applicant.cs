
using api.Modules.Dependents.Entity;
using api.Modules.Hubs.Entity;

namespace api.Modules.Applicants.Entity;


public class Applicant
{
  public Guid Id { get; init; }
  public string Name { get; private set; }
  public string CPF { get; private set; }
  public string Email { get; private set; }
  public string PhoneNumber { get; private set; }
  public string Address { get; private set; }
  public bool IsBeneficiary { get; private set; }
  public int BeneficiaryQtd { get; private set; } = 0;
  public DateTime CreatedAt { get; private init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // URL da foto de perfil
  public string? ProfileImageUrl { get; private set; }

  // Relacionamento com Hub
  public Guid HubId { get; private set; }
  public Hub Hub { get; private set; } = null!;

  // Propriedade de navegação
  public ICollection<Dependent>? Dependents { get; init; } = [];

  public Applicant(string name, string cpf, string email, string phoneNumber, string address, bool isBeneficiary, Guid hubId, string? profileImageUrl = null)
  {
    Id = Guid.NewGuid();
    Name = name;
    CPF = cpf;
    Email = email;
    PhoneNumber = phoneNumber;
    Address = address;
    IsBeneficiary = isBeneficiary;
    HubId = hubId;
    ProfileImageUrl = profileImageUrl;
  }

  private Applicant()
  {
    Id = Guid.NewGuid();
    Name = string.Empty;
    CPF = string.Empty;
    Email = string.Empty;
    PhoneNumber = string.Empty;
    Address = string.Empty;
    IsBeneficiary = false;
    HubId = Guid.Empty;
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

  public void SetIsBeneficiary(bool isBeneficiary)
  {
    IsBeneficiary = isBeneficiary;
  }

  public void SetBeneficiaryQtd(int beneficiaryQtd)
  {
    BeneficiaryQtd = beneficiaryQtd;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}