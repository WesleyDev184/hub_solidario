using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Stocks.Dto;

/// <summary>
/// DTO para atualização de stock via form-data, permitindo upload de arquivo
/// </summary>
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
