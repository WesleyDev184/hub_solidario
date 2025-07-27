using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Hubs.Dto;

// Create Hub
public record RequestCreateHubDto(
  [SwaggerParameter(Description = "Name of the hub", Required = true)]
  string Name,
  [SwaggerParameter(Description = "City of the hub", Required = true)]
  string City
);

public record RequestUpdateHubDto(
  [SwaggerParameter(Description = "Updated name of the hub", Required = false)]
  string? Name,
  [SwaggerParameter(Description = "Updated city of the hub", Required = false)]
  string? City
);