namespace api.Modules.Documents
{
  using System.Net;
  using DB;
  using Dto;
  using Dto.ExempleDoc;
  using Microsoft.Extensions.Caching.Hybrid;
  using Microsoft.AspNetCore.Http;
  using Microsoft.AspNetCore.Mvc;
  using api.Services.S3;
  using Swashbuckle.AspNetCore.Annotations;
  using Swashbuckle.AspNetCore.Filters;

  public static class DocumentsController
  {
    public static void DocumentRoutes(this WebApplication app)
    {
      RouteGroupBuilder group = app.MapGroup("/documents").WithTags("Documents");

      group.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new document",
          Description = "Creates a new document in the system.")
        ]
      [SwaggerResponse(
          StatusCodes.Status201Created,
          "Document created successfully.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Document already exists.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status201Created, typeof(ExampleResponseCreateDocumentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status409Conflict, typeof(ExampleResponseConflictDocumentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status400BadRequest, typeof(ExampleResponseBadRequestDocumentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError, typeof(ExampleResponseInternalServerErrorDocumentDTO))]
      [SwaggerRequestExample(
          typeof(RequestCreateDocumentDto),
          typeof(ExampleRequestCreateDocumentDTO))]
      async ([FromForm] RequestCreateDocumentDto request, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          // Validação básica
          if (request.DocumentFile == null || request.DocumentFile.Length == 0)
          {
            return Results.BadRequest(new ResponseControllerDocumentsDTO(
              HttpStatusCode.BadRequest,
              null,
              "Document file is required."));
          }

          // Upload do documento para o storage
          string documentUrl;
          await using (var stream = request.DocumentFile.OpenReadStream())
          {
            documentUrl = await fileStorageService.UploadFileAsync(
              stream,
              request.DocumentFile.FileName,
              request.DocumentFile.ContentType);
          }

          // Criar documento no banco
          var response = await DocumentService.CreateDocument(request, documentUrl, context, ct);

          if (response.StatusCode == HttpStatusCode.Created && response.Data != null)
          {
            // Invalidar caches relacionados
            await cache.InvalidateAllDocumentCaches(
              response.Data.Id,
              response.Data.ApplicantId,
              response.Data.DependentId);

            return Results.Created($"/documents/{response.Data.Id}", response);
          }

          // Se houve erro, deletar o arquivo do storage
          if (!string.IsNullOrEmpty(documentUrl))
          {
            try
            {
              var fileName = documentUrl.Split('/').Last();
              await fileStorageService.DeleteFileAsync(fileName);
            }
            catch (Exception ex)
            {
              Console.WriteLine($"Warning: Failed to delete uploaded document after error: {ex.Message}");
            }
          }

          return response.StatusCode switch
          {
            HttpStatusCode.BadRequest => Results.BadRequest(response),
            HttpStatusCode.Conflict => Results.Conflict(response),
            _ => Results.Json(response, statusCode: 500)
          };
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in create document endpoint: {ex.Message}");
          return Results.Json(new ResponseControllerDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      }).DisableAntiforgery();

      group.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get document by ID",
          Description = "Retrieves a document by its unique identifier.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Document retrieved successfully.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Document not found.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseGetDocumentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status404NotFound, typeof(ExampleResponseNotFoundDocumentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError, typeof(ExampleResponseInternalServerErrorDocumentDTO))]
      async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          var cachedResponse = await cache.GetOrSetDocumentCache(
            id,
            async cancel => await DocumentService.GetDocumentById(id, context, cancel),
            ct: ct);

          if (cachedResponse.StatusCode == HttpStatusCode.NotFound)
          {
            return Results.NotFound(cachedResponse);
          }

          if (cachedResponse.StatusCode == HttpStatusCode.OK)
          {
            return Results.Ok(cachedResponse);
          }

          return Results.Json(cachedResponse, statusCode: 500);
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in get document endpoint: {ex.Message}");
          return Results.Json(new ResponseControllerDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      });

      group.MapGet("/applicant/{applicantId:guid}",
        [SwaggerOperation(
          Summary = "Get documents by applicant ID",
          Description = "Retrieves all documents for a specific applicant.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Documents retrieved successfully.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseListDocumentsDTO))]
      async (Guid applicantId, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          var cachedResponse = await cache.GetOrSetDocumentsByApplicantCache(
            applicantId,
            async cancel => await DocumentService.GetDocumentsByApplicant(applicantId, context, cancel),
            ct: ct);

          if (cachedResponse.StatusCode == HttpStatusCode.NotFound)
          {
            return Results.NotFound(cachedResponse);
          }

          if (cachedResponse.StatusCode == HttpStatusCode.OK)
          {
            return Results.Ok(cachedResponse);
          }

          return Results.Json(cachedResponse, statusCode: 500);
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in get documents by applicant endpoint: {ex.Message}");
          return Results.Json(new ResponseDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      });

      group.MapGet("/dependent/{dependentId:guid}",
        [SwaggerOperation(
          Summary = "Get documents by dependent ID",
          Description = "Retrieves all documents for a specific dependent.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Documents retrieved successfully.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Dependent not found.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseDocumentsDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseListDocumentsDTO))]
      async (Guid dependentId, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          var cachedResponse = await cache.GetOrSetDocumentsByDependentCache(
            dependentId,
            async cancel => await DocumentService.GetDocumentsByDependent(dependentId, context, cancel),
            ct: ct);

          if (cachedResponse.StatusCode == HttpStatusCode.NotFound)
          {
            return Results.NotFound(cachedResponse);
          }

          if (cachedResponse.StatusCode == HttpStatusCode.OK)
          {
            return Results.Ok(cachedResponse);
          }

          return Results.Json(cachedResponse, statusCode: 500);
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in get documents by dependent endpoint: {ex.Message}");
          return Results.Json(new ResponseDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      });

      group.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update document",
          Description = "Updates an existing document.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Document updated successfully.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Document not found.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDocumentsDTO))]
      async (Guid id, [FromForm] RequestUpdateDocumentDto request, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          string? newDocumentUrl = null;

          // Upload novo documento se fornecido
          if (request.DocumentFile != null && request.DocumentFile.Length > 0)
          {
            await using var stream = request.DocumentFile.OpenReadStream();
            newDocumentUrl = await fileStorageService.UploadFileAsync(
              stream,
              request.DocumentFile.FileName,
              request.DocumentFile.ContentType);
          }

          // Atualizar documento
          var response = await DocumentService.UpdateDocument(id, request, context, fileStorageService, newDocumentUrl, ct);

          if (response.StatusCode == HttpStatusCode.OK && response.Data != null)
          {
            // Invalidar caches relacionados
            await cache.InvalidateAllDocumentCaches(
              response.Data.Id,
              response.Data.ApplicantId,
              response.Data.DependentId);

            return Results.Ok(response);
          }

          return response.StatusCode switch
          {
            HttpStatusCode.NotFound => Results.NotFound(response),
            HttpStatusCode.BadRequest => Results.BadRequest(response),
            _ => Results.Json(response, statusCode: 500)
          };
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in update document endpoint: {ex.Message}");
          return Results.Json(new ResponseControllerDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      }).DisableAntiforgery();

      group.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete document",
          Description = "Deletes an existing document.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Document deleted successfully.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Document not found.",
          typeof(ResponseControllerDocumentsDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDocumentsDTO))]
      async (Guid id, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>
      {
        try
        {
          // Buscar documento para obter IDs para invalidação de cache
          var documentResponse = await DocumentService.GetDocumentById(id, context, ct);
          if (documentResponse.StatusCode != HttpStatusCode.OK || documentResponse.Data == null)
          {
            return Results.NotFound(new ResponseControllerDocumentsDTO(
              HttpStatusCode.NotFound,
              null,
              "Document not found."));
          }

          var applicantId = documentResponse.Data.ApplicantId;
          var dependentId = documentResponse.Data.DependentId;

          // Deletar documento
          var response = await DocumentService.DeleteDocument(id, context, fileStorageService, ct);

          if (response.StatusCode == HttpStatusCode.OK)
          {
            // Invalidar caches relacionados
            await cache.InvalidateAllDocumentCaches(id, applicantId, dependentId);

            return Results.Ok(response);
          }

          return response.StatusCode switch
          {
            HttpStatusCode.NotFound => Results.NotFound(response),
            _ => Results.Json(response, statusCode: 500)
          };
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error in delete document endpoint: {ex.Message}");
          return Results.Json(new ResponseControllerDocumentsDTO(
            HttpStatusCode.InternalServerError,
            null,
            "An unexpected error occurred while processing the request."), statusCode: 500);
        }
      });
    }
  }
}
