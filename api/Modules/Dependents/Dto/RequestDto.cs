namespace api.Modules.Dependents.Dto;

using Swashbuckle.AspNetCore.Annotations;

// Create Dependent
public record RequestCreateDependentDto(
  [SwaggerParameter(Description = "Name of the dependent", Required = true)]
  string Name,
  [SwaggerParameter(Description = "CPF of the dependent", Required = true)]
  string CPF,
  [SwaggerParameter(Description = "Email of the dependent", Required = true)]
  string Email,
  [SwaggerParameter(Description = "Phone number of the dependent", Required = true)]
  string PhoneNumber,
  [SwaggerParameter(Description = "Address of the dependent", Required = true)]
  string Address,
  [SwaggerParameter(Description = "Identifier of the associated applicant", Required = true)]
  Guid ApplicantId
);

// Update Dependent
public record RequestUpdateDependentDto(
  [SwaggerParameter(Description = "Name of the dependent", Required = false)]
  string? Name,
  [SwaggerParameter(Description = "CPF of the dependent", Required = false)]
  string? CPF,
  [SwaggerParameter(Description = "Email of the dependent", Required = false)]
  string? Email,
  [SwaggerParameter(Description = "Phone number of the dependent", Required = false)]
  string? PhoneNumber,
  [SwaggerParameter(Description = "Address of the dependent", Required = false)]
  string? Address
);