namespace api.Modules.Documents.Dto;

using Swashbuckle.AspNetCore.Annotations;
using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

//Create Document
public class RequestCreateDocumentDto
{
  [SwaggerParameter(Description = "The document file to upload", Required = true)]
  [Required]
  public IFormFile DocumentFile { get; set; } = null!;

  [SwaggerParameter(Description = "The ID of the applicant this document belongs to", Required = true)]
  [Required]
  public Guid ApplicantId { get; set; }

  [SwaggerParameter(Description = "The ID of the dependent this document belongs to (optional)", Required = false)]
  public Guid? DependentId { get; set; }
}

//Update Document
public class RequestUpdateDocumentDto
{
  [SwaggerParameter(Description = "The new document file (optional)", Required = false)]
  public IFormFile? DocumentFile { get; set; }

  [SwaggerParameter(Description = "The ID of the dependent this document belongs to (optional)", Required = false)]
  public Guid? DependentId { get; set; }
}
