using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Stocks.Dto;

/// <summary>
/// DTO para criação de stock via form-data, permitindo upload de arquivo
/// </summary>
public class RequestCreateStockFormDto
{
  [Required]
  [SwaggerParameter(Description = "Title of the stock", Required = true)]
  public string Title { get; set; } = string.Empty;

  [SwaggerParameter(Description = "Image file of the stock", Required = false)]
  public IFormFile? ImageFile { get; set; }

  [Required]
  [SwaggerParameter(Description = "ID of the orthopedic bank to which the stock belongs", Required = true)]
  public Guid OrthopedicBankId { get; set; }
}
