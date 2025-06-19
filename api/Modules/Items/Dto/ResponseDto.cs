using System.Net;

namespace api.Modules.Items.Dto;

//Response Services
public record ResponseEntityItemDTO(Guid Id,
    int SeriaCode, string ImageUrl, string Status, DateTime CreatedAt);
public record ResponseItemDTO(HttpStatusCode Status, ResponseEntityItemDTO? Data, string? Message);
public record ResponseItemListDTO(HttpStatusCode Status, int Count, List<ResponseEntityItemDTO>? Data, string? Message);



//Response Controller
public record ResponseControllerItemDTO(bool Success, ResponseEntityItemDTO? Data, string? Message);
public record ResponseControllerItemListDTO(bool Success, int Count, List<ResponseEntityItemDTO>? Data, string? Message);
