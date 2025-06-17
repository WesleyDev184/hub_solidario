namespace api.Auth.Dto;

//Create User
public record RequestCreateUserDto(string Name, string Email, string Password, string PhoneNumber);

public record RequestUpdateUserDto(string? Name, string? Email, string? Password, string? PhoneNumber);

//Login User
public record RequestLoginUserDto(string Email, string Password);