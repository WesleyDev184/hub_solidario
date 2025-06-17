using api.Modules.Items.Enum;

namespace api.Modules.Items.Dto;

//Create Item
public record RequestCreateItemDto(int SeriaCode,
    Guid StockId,
    string? ImageUrl,
    ItemStatus Status);

public record RequestUpdateItemDto(
    int? SeriaCode,
    string? ImageUrl,
    ItemStatus? Status);