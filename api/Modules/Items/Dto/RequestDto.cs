using api.Modules.Items.Enum;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Items.Dto;

// Create Item
public record RequestCreateItemDto(
  [SwaggerParameter(Description = "Serial code of the item", Required = true)]
  int SeriaCode,
  [SwaggerParameter(Description = "Identifier of the stock", Required = true)]
  Guid StockId
);

public record RequestUpdateItemDto(
  [SwaggerParameter(Description = "Serial code of the item", Required = false)]
  int? SeriaCode,
  [SwaggerParameter(Description = "Status of the item", Required = false)]
  ItemStatus? Status
);