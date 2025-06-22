namespace api.Modules.Applicants.Dto;

using Swashbuckle.AspNetCore.Annotations;

//Create Applicant
public record RequestCreateApplicantDto(
  [SwaggerParameter(Description = "The name of the applicant", Required = true)]
  string Name,
  [SwaggerParameter(Description = "The CPF of the applicant", Required = true)]
  string CPF,
  [SwaggerParameter(Description = "The email of the applicant", Required = true)]
  string Email,
  [SwaggerParameter(Description = "The phone number of the applicant", Required = true)]
  string PhoneNumber,
  [SwaggerParameter(Description = "The address of the applicant", Required = true)]
  string Address,
  [SwaggerParameter(Description = "Indicator if the applicant is a beneficiary", Required = true)]
  bool IsBeneficiary
);

public record RequestUpdateApplicantDto(
  [SwaggerParameter(Description = "The name of the applicant", Required = false)]
  string? Name,
  [SwaggerParameter(Description = "The CPF of the applicant", Required = false)]
  string? CPF,
  [SwaggerParameter(Description = "The email of the applicant", Required = false)]
  string? Email,
  [SwaggerParameter(Description = "The phone number of the applicant", Required = false)]
  string? PhoneNumber,
  [SwaggerParameter(Description = "The address of the applicant", Required = false)]
  string? Address,
  [SwaggerParameter(Description = "Indicator if the applicant is a beneficiary", Required = false)]
  bool? IsBeneficiary
);