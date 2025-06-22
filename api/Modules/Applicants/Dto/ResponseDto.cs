namespace api.Modules.Applicants.Dto;

using System.Net;
using api.Modules.Dependents.Dto;
using Swashbuckle.AspNetCore.Annotations;

// Response Services
public record ResponseEntityApplicantsDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the applicant", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Name of the applicant", Format = "string")]
  string Name,
  [property: SwaggerSchema(Description = "CPF of the applicant", Format = "string")]
  string CPF,
  [property: SwaggerSchema(Description = "Email of the applicant", Format = "email")]
  string Email,
  [property: SwaggerSchema(Description = "Phone number of the applicant", Format = "string")]
  string PhoneNumber,
  [property: SwaggerSchema(Description = "Address of the applicant", Format = "string")]
  string Address,
  [property: SwaggerSchema(Description = "Indicator if the applicant is a beneficiary", Format = "boolean")]
  bool IsBeneficiary,
  [property: SwaggerSchema(Description = "Quantity of beneficiaries", Format = "int32")]
  int BeneficiaryQtd,
  [property: SwaggerSchema(Description = "Creation date of the applicant", Format = "date-time")]
  DateTime CreatedAt,
  [property: SwaggerSchema(Description = "Array of dependents associated with the applicant", Nullable = true)]
  ResponseEntityDependentDTO[]? Dependents
);

public record ResponseApplicantsDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Applicant data", Nullable = true)]
  ResponseEntityApplicantsDTO? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseApplicantsListDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Count of applicants returned in the response", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of applicant data", Nullable = true)]
  List<ResponseEntityApplicantsDTO>? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

// Response Controller
public record ResponseControllerApplicantsDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Applicant data if the operation was successful", Nullable = true)]
  ResponseEntityApplicantsDTO? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);

public record ResponseControllerApplicantsListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of applicants returned in the response", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of applicant data", Nullable = true)]
  List<ResponseEntityApplicantsDTO>? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);