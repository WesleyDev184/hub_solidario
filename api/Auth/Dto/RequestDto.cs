namespace api.Auth.Dto;

using api.Auth.Entity;
using Swashbuckle.AspNetCore.Annotations;

//Create User
public record RequestCreateUserDto(
  [SwaggerParameter(Description = "The name of the user", Required = true)]
  string Name,
  [SwaggerParameter(Description = "The email of the user", Required = true)]
  string Email,
  [SwaggerParameter(Description = "The password of the user", Required = true)]
  string Password,
  [SwaggerParameter(Description = "The phone number of the user", Required = true)]
  string PhoneNumber,
  [SwaggerParameter(Description = "The ID of the hub associated with the user", Required = true)]
  Guid HubId
);

public record RequestUpdateUserDto(
  [SwaggerParameter(Description = "The name of the user", Required = false)]
  string? Name,
  [SwaggerParameter(Description = "The email of the user", Required = false)]
  string? Email,
  [SwaggerParameter(Description = "The password of the user", Required = false)]
  string? Password,
  [SwaggerParameter(Description = "The phone number of the user", Required = false)]
  string? PhoneNumber
);

//Login User
public record RequestLoginUserDto(
  [SwaggerParameter(Description = "The email of the user", Required = true)]
  string Email,
  [SwaggerParameter(Description = "The password of the user", Required = true)]
  string Password);