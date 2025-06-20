using System.Net;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Dependents.Dto;

// Response Services
public record ResponseEntityDependentDTO(
    [property: SwaggerSchema(Description = "Unique identifier of the dependent", Format = "uuid")]
    Guid Id,

    [property: SwaggerSchema(Description = "Name of the dependent", Format = "string")]
    string Name,

    [property: SwaggerSchema(Description = "CPF of the dependent", Format = "string")]
    string CPF,

    [property: SwaggerSchema(Description = "Email of the dependent", Format = "email")]
    string Email,

    [property: SwaggerSchema(Description = "Phone number of the dependent", Format = "string")]
    string PhoneNumber,

    [property: SwaggerSchema(Description = "Address of the dependent", Format = "string")]
    string Address,

    [property: SwaggerSchema(Description = "Identifier of the associated applicant", Format = "uuid")]
    Guid ApplicantId,

    [property: SwaggerSchema(Description = "Creation date of the dependent", Format = "date-time")]
    DateTime CreatedAt
);

public record ResponseDependentDTO(
    [property: SwaggerSchema(Description = "HTTP status code of the response")]
    HttpStatusCode Status,

    [property: SwaggerSchema(Description = "Dependent data", Nullable = true)]
    ResponseEntityDependentDTO? Data,

    [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
    string? Message
);

public record ResponseDependentListDTO(
    [property: SwaggerSchema(Description = "HTTP status code of the response")]
    HttpStatusCode Status,

    [property: SwaggerSchema(Description = "Count of dependents returned", Format = "int32")]
    int Count,

    [property: SwaggerSchema(Description = "List of dependent data", Nullable = true)]
    List<ResponseEntityDependentDTO>? Data,

    [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
    string? Message
);

// Response Controller
public record ResponseControllerDependentDTO(
    [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
    bool Success,

    [property: SwaggerSchema(Description = "Dependent data if the operation was successful", Nullable = true)]
    ResponseEntityDependentDTO? Data,

    [property: SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
    string? Message
);

public record ResponseControllerDependentListDTO(
    [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
    bool Success,

    [property: SwaggerSchema(Description = "Count of dependents returned", Format = "int32")]
    int Count,

    [property: SwaggerSchema(Description = "List of dependent data if the operation was successful", Nullable = true)]
    List<ResponseEntityDependentDTO>? Data,

    [property: SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
    string? Message
);