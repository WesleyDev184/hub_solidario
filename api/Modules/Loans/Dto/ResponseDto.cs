using System.Net;
using api.Auth.Dto;
using api.Modules.Applicants.Dto;
using api.Modules.Items.Dto;

namespace api.Modules.Loans.Dto;

//Response Services
public record ResponseEntityLoanDTO(
    Guid Id,
    DateTime? ReturnDate,
    string Reason,
    bool IsActive,
    ResponseEntityItemDTO? Item,
    ResponseEntityApplicantsDTO? Applicant,
    ResponseEntityUserDTO? Responsible,
    DateTime CreatedAt
);

public record ResponseEntityLoanListDTO(
    Guid Id,
    DateTime? ReturnDate,
    string Reason,
    bool IsActive,
    int? Item,
    string? Applicant,
    string? Responsible,
    DateTime CreatedAt
);

public record ResponseLoanDTO(HttpStatusCode Status, ResponseEntityLoanDTO? Data, string? Message);
public record ResponseLoanListDTO(HttpStatusCode Status, int Count, List<ResponseEntityLoanListDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerLoanDTO(bool Success, ResponseEntityLoanDTO? Data, string? Message);
public record ResponseControllerLoanListDTO(bool Success, int Count, List<ResponseEntityLoanListDTO>? Data, string? Message);