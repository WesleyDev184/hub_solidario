using System.Net;

namespace api.Modules.Dependents.Dto;

//Response Services
public record ResponseEntityDependentDTO(
    Guid Id,
    string Name,
    string CPF,
    string Email,
    string PhoneNumber,
    string Address,
    Guid ApplicantId,
    DateTime CreatedAt
);

public record ResponseDependentDTO(HttpStatusCode Status, ResponseEntityDependentDTO? Data, string? Message);
public record ResponseDependentListDTO(HttpStatusCode Status, int Count, List<ResponseEntityDependentDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerDependentDTO(bool Success, ResponseEntityDependentDTO? Data, string? Message);
public record ResponseControllerDependentListDTO(bool Success, int Count, List<ResponseEntityDependentDTO>? Data, string? Message);