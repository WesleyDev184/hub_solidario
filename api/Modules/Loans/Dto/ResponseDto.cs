using System.Net;
using api.Auth.Dto;
using api.Modules.Applicants.Dto;
using api.Modules.Items.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Loans.Dto;

// Response Services
public record ResponseEntityLoanDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the loan", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Return date of the loan", Format = "date-time", Nullable = true)]
  DateTime? ReturnDate,
  [property: SwaggerSchema(Description = "Reason for the loan", Format = "string")]
  string Reason,
  [property: SwaggerSchema(Description = "Indicates whether the loan is active", Format = "boolean")]
  bool IsActive,
  [property: SwaggerSchema(Description = "Item data related to the loan", Nullable = true)]
  ResponseEntityItemDTO? Item,
  [property: SwaggerSchema(Description = "Applicant data related to the loan", Nullable = true)]
  ResponseEntityApplicantsDTO? Applicant,
  [property: SwaggerSchema(Description = "User responsible for the loan", Nullable = true)]
  ResponseEntityUserDTO? Responsible,
  [property: SwaggerSchema(Description = "Creation date of the loan", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseEntityLoanListDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the loan", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Return date of the loan", Format = "date-time", Nullable = true)]
  DateTime? ReturnDate,
  [property: SwaggerSchema(Description = "Reason for the loan", Format = "string")]
  string Reason,
  [property: SwaggerSchema(Description = "Indicates whether the loan is active", Format = "boolean")]
  bool IsActive,
  [property: SwaggerSchema(Description = "Identifier of the item being loaned", Format = "int32", Nullable = true)]
  int? Item,
  [property: SwaggerSchema(Description = "Name of the applicant", Format = "string", Nullable = true)]
  string? Applicant,
  [property: SwaggerSchema(Description = "Name of the responsible user", Format = "string", Nullable = true)]
  string? Responsible,
  [property: SwaggerSchema(Description = "Creation date of the loan", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseLoanDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Loan data", Nullable = true)]
  ResponseEntityLoanDTO? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseLoanDeleteDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Loan data", Nullable = true)]
  Guid? StockId,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseLoanListDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Count of loans returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of loan data", Nullable = true)]
  List<ResponseEntityLoanListDTO>? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

// Response Controller
public record ResponseControllerLoanDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Loan data if the operation was successful", Nullable = true)]
  ResponseEntityLoanDTO? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);

public record ResponseControllerLoanListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of loans returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of loan data if the operation was successful", Nullable = true)]
  List<ResponseEntityLoanListDTO>? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);