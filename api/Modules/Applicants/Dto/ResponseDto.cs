using System.Net;
using api.Modules.Dependents.Dto;

namespace api.Modules.Applicants.Dto;

//Response Services
public record ResponseEntityApplicantsDTO(
    Guid Id,
    string Name,
    string CPF,
    string Email,
    string PhoneNumber,
    string Address,
    bool IsBeneficiary,
    int BeneficiaryQtd,
    DateTime CreatedAt,
    ResponseEntityDependentDTO[]? Dependents
);

public record ResponseApplicantsDTO(HttpStatusCode Status, ResponseEntityApplicantsDTO? Data, string? Message);
public record ResponseApplicantsListDTO(HttpStatusCode Status, int Count, List<ResponseEntityApplicantsDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerApplicantsDTO(bool Success, ResponseEntityApplicantsDTO? Data, string? Message);
public record ResponseControllerApplicantsListDTO(bool Success, int Count, List<ResponseEntityApplicantsDTO>? Data, string? Message);