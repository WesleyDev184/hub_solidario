namespace api.Modules.Stocks.Dto;

using Swashbuckle.AspNetCore.Annotations;

// Create Stock
public record RequestCreateStockDto(
  [SwaggerParameter(Description = "Title of the stock", Required = true)]
  string Title,
  [SwaggerParameter(Description = "Image file of the stock", Required = true)]
  IFormFile? ImageFile,
  [SwaggerParameter(Description = "ID of the orthopedic bank to which the stock belongs", Required = true)]
  Guid OrthopedicBankId
);

public record RequestUpdateStockDto(
  [SwaggerParameter(Description = "Updated title of the stock", Required = false)]
  string? Title,
  [SwaggerParameter(Description = "New image file of the stock", Required = false)]
  IFormFile? ImageFile,
  [SwaggerParameter(Description = "Quantity for maintenance", Required = false)]
  int? MaintenanceQtd,
  [SwaggerParameter(Description = "Quantity available", Required = false)]
  int? AvailableQtd,
  [SwaggerParameter(Description = "Quantity borrowed", Required = false)]
  int? BorrowedQtd
);