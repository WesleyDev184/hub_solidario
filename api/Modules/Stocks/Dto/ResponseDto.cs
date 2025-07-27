using System.Net;
using api.Modules.Items.Dto;
using api.Modules.Hubs.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Stocks.Dto;

// Response Services
// Ensure only one definition exists for ResponseEntityStockDTO in this file and namespace.
// If you need to keep this record, remove any other conflicting or duplicate definitions of ResponseEntityStockDTO from this file or other files in the same namespace.
public record ResponseEntityStockDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the stock", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Title of the stock", Format = "string")]
  string Title,
  [property: SwaggerSchema(Description = "Image URL of the stock", Format = "string")]
  string ImageUrl,
  [property: SwaggerSchema(Description = "Quantity for maintenance", Format = "int32")]
  int MaintenanceQtd,
  [property: SwaggerSchema(Description = "Quantity available", Format = "int32")]
  int AvailableQtd,
  [property: SwaggerSchema(Description = "Quantity borrowed", Format = "int32")]
  int BorrowedQtd,
  [property: SwaggerSchema(Description = "Total quantity", Format = "int32")]
  int TotalQtd,
  [property: SwaggerSchema(Description = "Unique identifier of the Hub", Format = "uuid", Nullable = true)]
  Guid? HubId,
  [property: SwaggerSchema(Description = "Hub", Nullable = true)]
  ResponseEntityHubDTO? Hub,
  [property: SwaggerSchema(Description = "Items associated with the stock", Nullable = true)]
  ResponseEntityItemDTO[]? Items,
  [property: SwaggerSchema(Description = "Creation date of the stock", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseStockDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Stock data", Nullable = true)]
  ResponseEntityStockDTO? Data,
  [property: SwaggerSchema(Description = "Additional message", Nullable = true)]
  string? Message
);

public record ResponseStockDeleteDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Unique identifier of the Hub", Format = "uuid", Nullable = true)]
  Guid? HubId,
  [property: SwaggerSchema(Description = "Additional message", Nullable = true)]
  string? Message
);

public record ResponseStockListDTO(
  [property: SwaggerSchema(Description = "HTTP status code of the response")]
  HttpStatusCode Status,
  [property: SwaggerSchema(Description = "Count of stocks returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of stock data", Nullable = true)]
  List<ResponseEntityStockDTO>? Data,
  [property: SwaggerSchema(Description = "Additional message", Nullable = true)]
  string? Message
);

// Response Controller
public record ResponseControllerStockDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Stock data if the operation was successful", Nullable = true)]
  ResponseEntityStockDTO? Data,
  [property: SwaggerSchema(Description = "Message providing additional information", Nullable = true)]
  string? Message
);

public record ResponseControllerStockListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of stocks returned", Format = "int32")]
  int Count,
  [property: SwaggerSchema(Description = "List of stock data if the operation was successful", Nullable = true)]
  List<ResponseEntityStockDTO>? Data,
  [property: SwaggerSchema(Description = "Message providing additional information", Nullable = true)]
  string? Message
);