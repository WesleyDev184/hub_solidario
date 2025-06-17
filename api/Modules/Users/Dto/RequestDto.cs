namespace api.Modules.Users.Dto;

//Create User
public record RequestCreateUserDto(string Name, string Email, string Password, string Phone);

public record RequestUpdateUserDto(string? Name, string? Email, string? Password, string? Phone);