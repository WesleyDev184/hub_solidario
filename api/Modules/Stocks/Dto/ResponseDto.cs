using System.Net;
using api.Modules.Items.Dto;

namespace api.Modules.Stocks.Dto;

//Response Services
public record ResponseEntityStockDTO(Guid Id, string Title,
    int MaintenanceQtd, int AvailableQtd, int BorrowedQtd, int TotalQtd, ResponseEntityItemDTO[]? Items,
    DateTime CreatedAt);

internal class RespondseEntityItemDTO
{
}

public record ResponseStockDTO(HttpStatusCode Status, ResponseEntityStockDTO? Data, string? Message);
public record ResponseStockListDTO(HttpStatusCode Status, int Count, List<ResponseEntityStockDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerStockDTO(bool Success, ResponseEntityStockDTO? Data, string? Message);
public record ResponseControllerStockListDTO(bool Success, int Count, List<ResponseEntityStockDTO>? Data, string? Message);