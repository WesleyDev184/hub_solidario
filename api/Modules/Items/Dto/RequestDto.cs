using api.Modules.Items.Enum;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Items.Dto;

// Create Item
public record RequestCreateItemDto(
    [SwaggerParameter(Description = "Serial code of the item", Required = true)]
    int SeriaCode,

    [SwaggerParameter(Description = "Identifier of the stock", Required = true)]
    Guid StockId,

    [SwaggerParameter(Description = "Image URL for the item", Required = false)]
    string? ImageUrl
);

public record RequestUpdateItemDto(
    [SwaggerParameter(Description = "Serial code of the item", Required = false)]
    int? SeriaCode,

    [SwaggerParameter(Description = "Image URL for the item", Required = false)]
    string? ImageUrl,

    [SwaggerParameter(Description = "Status of the item", Required = false)]
    ItemStatus? Status
);