using System.Net;

namespace api.Auth.Dto;

//Response Services
public record ResponseEntityUserDTO(Guid Id, string Name, string Email, string PhoneNumber, DateTime CreatedAt);
public record ResponseUserDTO(HttpStatusCode Status, ResponseEntityUserDTO? Data, string? Message);
public record ResponseUserListDTO(HttpStatusCode Status, int Count, List<ResponseEntityUserDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerUserDTO(bool Success, ResponseEntityUserDTO? Data, string? Message);
public record ResponseControllerUserListDTO(bool Success, int Count, List<ResponseEntityUserDTO> Data, string? Message);