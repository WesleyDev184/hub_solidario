using System.Net;

namespace api.Modules.OrthopedicBanks.Dto;

//Response Services
public record ResponseEntityOrthopedicBankDTO(Guid Id, string Name, string City, DateTime CreatedAt);
public record ResponseOrthopedicBankDTO(HttpStatusCode Status, ResponseEntityOrthopedicBankDTO? Data, string? Message);
public record ResponseOrthopedicBankListDTO(HttpStatusCode Status, int Count, List<ResponseEntityOrthopedicBankDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerOrthopedicBankDTO(bool Success, ResponseEntityOrthopedicBankDTO? Data, string? Message);
public record ResponseControllerOrthopedicBankListDTO(bool Success, int Count, List<ResponseEntityOrthopedicBankDTO>? Data, string? Message);