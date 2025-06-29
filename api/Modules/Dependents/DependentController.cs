using System.Net;
using api.DB;
using api.Modules.Dependents.Dto;
using api.Modules.Dependents.Dto.ExampleDoc;
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
          Description = "Creates a new dependent in the system.")
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
      async (RequestCreateDependentDto request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.CreateDependent(request, context, ct);

          // Invalidar cache após criação bem-sucedida
          if (response.Status == HttpStatusCode.Created)
          {
            await DependentCacheService.InvalidateOnDependentCreated(cache, request.ApplicantId, ct);
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
        }).RequireAuthorization();

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
              Expiration = TimeSpan.FromMinutes(5),
              LocalCacheExpiration = TimeSpan.FromMinutes(2)
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
              Expiration = TimeSpan.FromMinutes(3),
              LocalCacheExpiration = TimeSpan.FromMinutes(1)
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
          Description = "Updates an existing dependent in the system.")
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
      async (Guid id, RequestUpdateDependentDto request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.UpdateDependent(id, request, context, ct);

          // Invalidar cache após atualização bem-sucedida
          if (response.Status == HttpStatusCode.OK)
          {
            await DependentCacheService.InvalidateOnDependentUpdated(cache, id, ct: ct);
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
        }).RequireAuthorization();

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
      async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.DeleteDependent(id, context, ct);

          // Invalidar cache após exclusão bem-sucedida
          if (response.Status == HttpStatusCode.OK)
          {
            await DependentCacheService.InvalidateOnDependentDeleted(cache, id, ct);
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