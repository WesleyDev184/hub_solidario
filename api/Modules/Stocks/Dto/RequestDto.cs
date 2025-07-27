namespace api.Modules.Stocks.Dto;

using Swashbuckle.AspNetCore.Annotations;
using System.ComponentModel.DataAnnotations;

// Create Stock
public class RequestCreateStockFormDto
{
  [Required]
  [SwaggerParameter(Description = "Title of the stock", Required = true)]
  public string Title { get; set; } = string.Empty;

  [SwaggerParameter(Description = "Image file of the stock", Required = false)]
  public IFormFile? ImageFile { get; set; }

  [Required]
  [SwaggerParameter(Description = "ID of the orthopedic bank to which the stock belongs", Required = true)]
  public Guid HubId { get; set; }
}

public class RequestUpdateStockFormDto
{
  [SwaggerParameter(Description = "Updated title of the stock", Required = false)]
  public string? Title { get; set; }

  [SwaggerParameter(Description = "New image file of the stock", Required = false)]
  public IFormFile? ImageFile { get; set; }

  [SwaggerParameter(Description = "Quantity for maintenance", Required = false)]
  public int? MaintenanceQtd { get; set; }

  [SwaggerParameter(Description = "Quantity available", Required = false)]
  public int? AvailableQtd { get; set; }

  [SwaggerParameter(Description = "Quantity borrowed", Required = false)]
  public int? BorrowedQtd { get; set; }
}

// Create Stock
public record RequestCreateStockDto(
  [SwaggerParameter(Description = "Title of the stock", Required = true)]
  string Title,
  [SwaggerParameter(Description = "Image file of the stock", Required = true)]
  IFormFile? ImageFile,
  [SwaggerParameter(Description = "ID of the orthopedic bank to which the stock belongs", Required = true)]
  Guid HubId
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