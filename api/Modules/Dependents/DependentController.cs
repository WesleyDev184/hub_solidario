using System.Net;
using api.DB;
using api.Modules.Dependents.Dto;
using api.Modules.Dependents.Dto.ExampleDoc;
using api.Services.S3;
using Microsoft.Extensions.Caching.Hybrid;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Dependents
{
  public static class DependentController
  {
    public static void DependentRoutes(this WebApplication app)
    {
      RouteGroupBuilder group = app.MapGroup("/dependents").WithTags("Dependents");

      group.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new dependent",
          Description = "Creates a new dependent in the system. Accepts multipart/form-data for image upload.")
        ]
      [SwaggerResponse(
          StatusCodes.Status201Created,
          "Dependent created successfully.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Dependent already exists.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestDependentDTO))]
      [SwaggerResponseExample(StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentApplicantNotFoundDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
      [SwaggerRequestExample(
          typeof(RequestCreateDependentDto),
          typeof(ExampleRequestCreateDependentDto))]
      async (HttpRequest httpRequest, ApiDbContext context, HybridCache cache, IFileStorageService fileStorage, CancellationToken ct) =>
        {
          var form = await httpRequest.ReadFormAsync(ct);
          var dto = new RequestCreateDependentDto(
            form["Name"].FirstOrDefault() ?? string.Empty,
            form["CPF"].FirstOrDefault() ?? string.Empty,
            form["Email"].FirstOrDefault() ?? string.Empty,
            form["PhoneNumber"].FirstOrDefault() ?? string.Empty,
            form["Address"].FirstOrDefault() ?? string.Empty,
            Guid.TryParse(form["ApplicantId"].FirstOrDefault(), out var applicantId) ? applicantId : Guid.Empty,
            form.Files.GetFile("ProfileImage")
          );

          string? imageUrl = null;
          if (dto.ProfileImage != null && dto.ProfileImage.Length > 0)
          {
            using var stream = dto.ProfileImage.OpenReadStream();
            imageUrl = await fileStorage.UploadFileAsync(stream, dto.ProfileImage.FileName, dto.ProfileImage.ContentType);
          }

          var response = await DependentService.CreateDependent(dto, context, imageUrl, ct);

          // Invalidar cache global após criação bem-sucedida
          if (response.Status == HttpStatusCode.Created)
          {
            await DependentCacheService.InvalidateDependentCache(cache, response.Data!.Id, response.Data.ApplicantId, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Created($"/Dependents/{response.Data?.Id}",
              new ResponseControllerDependentDTO(response.Status == HttpStatusCode.Created, response.Data,
                response.Message))
          };
        }).Accepts<Microsoft.AspNetCore.Http.IFormFile>("multipart/form-data").RequireAuthorization();

      group.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get a dependent by ID",
          Description = "Retrieves a dependent from the system by its unique identifier.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Dependent retrieved successfully.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Dependent not found.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentNotFoundDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetDependentDTO))]
      async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = DependentCacheService.Keys.DependentById(id);

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await DependentService.GetDependent(id, context, cancel),
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromMinutes(30),
              LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
            },
            cancellationToken: ct);

          if (cachedResponse.Status == HttpStatusCode.NotFound)
          {
            return Results.NotFound(new ResponseControllerDependentDTO(
              false,
              null,
              cachedResponse.Message));
          }

          return Results.Ok(new ResponseControllerDependentDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Data,
            cachedResponse.Message));
        }).RequireAuthorization();

      group.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all dependents",
          Description = "Retrieves a list of all dependents in the system.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Dependents retrieved successfully.",
          typeof(ResponseControllerDependentListDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllDependentDTO))]
      async (ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = DependentCacheService.Keys.AllDependents;

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await DependentService.GetDependents(context, cancel),
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
            },
            cancellationToken: ct);

          return Results.Ok(new ResponseControllerDependentListDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Count,
            cachedResponse.Data,
            cachedResponse.Message));
        }).RequireAuthorization();

      group.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update a dependent",
          Description = "Updates an existing dependent in the system. Accepts multipart/form-data for image update.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Dependent updated successfully.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Dependent not found.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Conflict error occurred.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentOrApplicantNotFoundDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateDependentDTO))]
      [SwaggerRequestExample(
          typeof(RequestUpdateDependentDto),
          typeof(ExampleRequestUpdateDependentDto))]
      async (Guid id, HttpRequest httpRequest, ApiDbContext context, HybridCache cache, IFileStorageService fileStorage, CancellationToken ct) =>
        {
          var form = await httpRequest.ReadFormAsync(ct);
          var dto = new RequestUpdateDependentDto(
            form["Name"].FirstOrDefault(),
            form["CPF"].FirstOrDefault(),
            form["Email"].FirstOrDefault(),
            form["PhoneNumber"].FirstOrDefault(),
            form["Address"].FirstOrDefault(),
            form.Files.GetFile("ProfileImage")
          );

          string? imageUrl = null;
          if (dto.ProfileImage != null && dto.ProfileImage.Length > 0)
          {
            using var stream = dto.ProfileImage.OpenReadStream();
            imageUrl = await fileStorage.UploadFileAsync(stream, dto.ProfileImage.FileName, dto.ProfileImage.ContentType);
          }

          var response = await DependentService.UpdateDependent(id, dto, context, fileStorage, imageUrl, ct);

          // Invalidar cache apenas do dependent alterado após atualização
          if (response.Status == HttpStatusCode.OK)
          {
            await DependentCacheService.InvalidateDependentCache(cache, id, response.Data!.ApplicantId, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerDependentDTO(response.Status == HttpStatusCode.OK, response.Data,
              response.Message))
          };
        }).Accepts<Microsoft.AspNetCore.Http.IFormFile>("multipart/form-data").RequireAuthorization();

      group.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete a dependent",
          Description = "Deletes a dependent from the system by its unique identifier.")
        ]
      [SwaggerResponse(
          StatusCodes.Status200OK,
          "Dependent deleted successfully.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Dependent not found.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentNotFoundDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteDependentDTO))]
      [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
      async (Guid id, ApiDbContext context, HybridCache cache, IFileStorageService fileStorage, CancellationToken ct) =>
        {
          var response = await DependentService.DeleteDependent(id, context, fileStorage, ct);

          // Invalidar cache apenas do dependent excluído
          if (response.Status == HttpStatusCode.OK)
          {
            await DependentCacheService.InvalidateDependentCache(cache, id, response.ApplicantId, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerDependentDTO(response.Status == HttpStatusCode.OK, null,
              response.Message))
          };
        }).RequireAuthorization();
    }
  }
}