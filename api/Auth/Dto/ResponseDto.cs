using System.Net;
using api.Modules.Hubs.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Auth.Dto;

//Response Services
public record ResponseEntityUserDTO(
  [property: SwaggerSchema(Description = "Unique identifier of the user", Format = "uuid")]
  Guid Id,
  [property: SwaggerSchema(Description = "Name of the user", Format = "string")]
  string Name,
  [property: SwaggerSchema(Description = "Email of the user", Format = "email")]
  string Email,
  [property: SwaggerSchema(Description = "Phone number of the user", Format = "string")]
  string PhoneNumber,
  [property: SwaggerSchema(Description = "Hub associated with the user")]
  ResponseEntityHubDTO? Hub,
  [property: SwaggerSchema(Description = "Creation date of the user", Format = "date-time")]
  DateTime CreatedAt
);

public record ResponseUserDTO(HttpStatusCode Status, ResponseEntityUserDTO? Data, string? Message);

public record ResponseUserListDTO(HttpStatusCode Status, int Count, List<ResponseEntityUserDTO>? Data, string? Message);

//Response Controller
public record ResponseControllerUserDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Data of the user if the operation was successful")]
  ResponseEntityUserDTO? Data,
  [property: SwaggerSchema(Description = "Message providing additional information about the operation")]
  string? Message
);

public record ResponseControllerUserListDTO(
  [property: SwaggerSchema(Description = "Indicates whether the operation was successful")]
  bool Success,
  [property: SwaggerSchema(Description = "Count of users returned in the response")]
  int Count,
  [property: SwaggerSchema(Description = "List of user data if the operation was successful")]
  List<ResponseEntityUserDTO> Data,
  [property: SwaggerSchema(Description = "Message providing additional information about the operation")]
  string? Message);