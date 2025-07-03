using System.Net;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Items.Dto;

// Response Services
public record ResponseEntityItemDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the item", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Serial code of the item", Format = "int32")]
  int SeriaCode,
  [property: SwaggerSchema(Description = "Status of the item", Format = "string")]
  string Status,
  [property: SwaggerSchema(Description = "Unique identifier of the stock associated with the item", Format = "uuid")]
  Guid StockId,
  [property: SwaggerSchema(Description = "Creation date of the item", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseItemDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Item data", Nullable = true)]
  ResponseEntityItemDTO? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseItemDeleteDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Unique identifier of the Stock", Format = "uuid", Nullable = true)]
  Guid? Id,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

public record ResponseItemListDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Count of items returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of item data", Nullable = true)]
  List<ResponseEntityItemDTO>? Data,
  [property: SwaggerSchema(Description = "Additional message information", Nullable = true)]
  string? Message
);

// Response Controller
public record ResponseControllerItemDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Item data if the operation was successful", Nullable = true)]
  ResponseEntityItemDTO? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);

public record ResponseControllerItemListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of items returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of item data if the operation was successful", Nullable = true)]
  List<ResponseEntityItemDTO>? Data,
  [property:
    SwaggerSchema(Description = "Message providing additional information about the operation", Nullable = true)]
  string? Message
);