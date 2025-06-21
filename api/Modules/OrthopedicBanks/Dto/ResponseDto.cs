using System.Net;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.OrthopedicBanks.Dto;

// Response Services
public record ResponseEntityOrthopedicBankDTO(
    [property: SwaggerSchema(Description = "Unique identifier of the orthopedic bank", Format = "uuid")]
    Guid Id,

    [property: SwaggerSchema(Description = "Name of the orthopedic bank", Format = "string")]
    string Name,

    [property: SwaggerSchema(Description = "City of the orthopedic bank", Format = "string")]
    string City,

    [property: SwaggerSchema(Description = "Creation date of the orthopedic bank", Format = "date-time")]
    DateTime CreatedAt
);

public record ResponseOrthopedicBankDTO(
    [property: SwaggerSchema(Description = "HTTP status code of the response")]
    HttpStatusCode Status,

    [property: SwaggerSchema(Description = "Orthopedic bank data", Nullable = true)]
    ResponseEntityOrthopedicBankDTO? Data,

    [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
    string? Message
);

public record ResponseOrthopedicBankListDTO(
    [property: SwaggerSchema(Description = "HTTP status code of the response")]
    HttpStatusCode Status,

    [property: SwaggerSchema(Description = "Count of orthopedic banks returned", Format = "int32")]
    int Count,

    [property: SwaggerSchema(Description = "List of orthopedic bank data", Nullable = true)]
    List<ResponseEntityOrthopedicBankDTO>? Data,

    [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
    string? Message
);

// Response Controller
public record ResponseControllerOrthopedicBankDTO(
    [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
    bool Success,

    [property: SwaggerSchema(Description = "Orthopedic bank data if the operation was successful", Nullable = true)]
    ResponseEntityOrthopedicBankDTO? Data,

    [property: SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
    string? Message
);

public record ResponseControllerOrthopedicBankListDTO(
    [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
    bool Success,

    [property: SwaggerSchema(Description = "Count of orthopedic banks returned", Format = "int32")]
    int Count,

    [property: SwaggerSchema(Description = "List of orthopedic bank data if the operation was successful", Nullable = true)]
    List<ResponseEntityOrthopedicBankDTO>? Data,

    [property: SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
    string? Message
);