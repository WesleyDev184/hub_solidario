namespace api.Modules.Applicants.Dto;

//Create Applicant
public record RequestCreateApplicantDto(string Name, string CPF, string Email, string PhoneNumber, string Address, bool IsBeneficiary);

public record RequestUpdateApplicantDto(
    string? Name,
    string? CPF,
    string? Email,
    string? PhoneNumber,
    string? Address,
    bool? IsBeneficiary
);