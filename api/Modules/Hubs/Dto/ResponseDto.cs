using api.Modules.Stocks.Dto;
using System.Net;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Hubs.Dto;

// Response Services
public record ResponseEntityHubDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the hub", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Name of the hub", Format = "string")]
  string Name,
  [property: SwaggerSchema(Description = "City of the hub", Format = "string")]
  string City,
  [property: SwaggerSchema(Description = "List of hub stocks", Format = "string")]
  ResponseEntityStockDTO[]? Stocks,
  [property: SwaggerSchema(Description = "Creation date of the hub", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseHubDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "hub data", Nullable = true)]
  ResponseEntityHubDTO? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseHubListDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Count of hubs returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of hub data", Nullable = true)]
  List<ResponseEntityHubDTO>? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

// Response Controller
public record ResponseControllerHubDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "hub data if the operation was successful", Nullable = true)]
  ResponseEntityHubDTO? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);

public record ResponseControllerHubListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of hubs returned", Format = "int32")]
  int Count,
  [property:
    SwaggerSchema(Description = "List of hub data if the operation was successful", Nullable = true)]
  List<ResponseEntityHubDTO>? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);