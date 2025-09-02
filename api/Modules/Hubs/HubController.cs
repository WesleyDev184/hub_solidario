using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;
using System.Net;
using api.DB;
using api.Modules.Hubs.Dto;
using api.Modules.Hubs.Dto.ExampleDoc;
using Microsoft.Extensions.Caching.Hybrid;

namespace api.Modules.Hubs;

public static class HubController
{
  public static void HubRoutes(this WebApplication app)
  {
    RouteGroupBuilder HubGroup = app.MapGroup("hubs")
      .WithTags("Hubs");

    HubGroup.MapPost("/",
        [
          SwaggerOperation(
            Summary = "Create a new hub",
            Description = "Creates a new hub in the system.")
        ]
    [SwaggerResponse(
          StatusCodes.Status201Created,
          "hub created successfully.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An error occurred while processing the request.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(StatusCodes.Status409Conflict,
          "hub already exists.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictHubDto))]
    [SwaggerRequestExample(
          typeof(RequestCreateHubDto),
          typeof(ExampleRequestCreateHubDto))]
    async (RequestCreateHubDto request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var res = await HubService.CreateHub(request, context, ct);

          // Invalidar cache após criação bem-sucedida
          if (res.Status == HttpStatusCode.Created)
          {
            await HubCacheService.InvalidateHubCache(cache, res.Data!.Id, null, ct);
          }

          return res.Status switch
          {
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerHubDTO(
              false, null, res.Message)),
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerHubDTO(
              false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Problem(detail: res.Message,
              statusCode: StatusCodes.Status500InternalServerError),
            _ => Results.Created($"/hubs/{res.Data?.Id}",
              new ResponseControllerHubDTO(res.Status == HttpStatusCode.Created, res.Data, res.Message))
          };
        })
      .WithName("CreateHub");

    HubGroup.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get an hub by ID",
          Description = "Retrieves an hub from the system by its unique identifier.")
        ]
    [SwaggerResponse(
          StatusCodes.Status200OK,
          "hub retrieved successfully.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "hub not found.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseHubNotFoundDto))]
    async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = HubCacheService.Keys.HubById(id);

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await HubService.GetHub(id, context, cancel),
            options: HubCacheService.CacheOptions.VeryLongTerm,
            cancellationToken: ct);

          if (cachedResponse.Status == HttpStatusCode.NotFound || cachedResponse.Data == null)
          {
            return Results.NotFound(new ResponseControllerHubDTO(
              false,
              null,
              cachedResponse.Message));
          }

          return Results.Ok(new ResponseControllerHubDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Data,
            cachedResponse.Message));
        })
      .RequireAuthorization()
      .WithName("GetHub");

    HubGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all hubs",
          Description = "Retrieves a list of all hubs in the system.")
        ]
    [SwaggerResponse(
          StatusCodes.Status200OK,
          "hubs retrieved successfully.",
          typeof(ResponseControllerHubListDTO))]
    [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllHubDto))]
    async (ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = HubCacheService.Keys.AllHubs;

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await HubService.GetHubs(context, cancel),
            options: HubCacheService.CacheOptions.VeryLongTerm,
            cancellationToken: ct,
            tags: new[] { HubCacheService.Tags.Hubs });

          return Results.Ok(new ResponseControllerHubListDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Count,
            cachedResponse.Data,
            cachedResponse.Message));
        })
      .WithName("GetHubs");

    HubGroup.MapPatch("/{id:guid}",
        [
          SwaggerOperation(
            Summary = "Update an hub",
            Description = "Updates an existing hub in the system.")
        ]
    [SwaggerResponse(
          StatusCodes.Status200OK,
          "hub updated successfully.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "hub not found.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "hub already exists.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An error occurred while processing the request.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseHubNotFoundDto))]
    [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorHubDto))]
    [SwaggerRequestExample(
          typeof(RequestUpdateHubDto),
          typeof(ExampleRequestUpdateHubDto))]
    async (Guid id, RequestUpdateHubDto request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>

        {
          var res = await HubService.UpdateHub(id, request, context, ct);

          // Invalidar cache após atualização bem-sucedida
          if (res.Status == HttpStatusCode.OK)
          {
            await HubCacheService.InvalidateHubCache(cache, id, null, ct);
          }

          return res.Status switch
          {
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerHubDTO(
              false, null, res.Message)),
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerHubDTO(
              false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Problem(detail: res.Message,
              statusCode: StatusCodes.Status500InternalServerError),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerHubDTO(
              false, null, res.Message)),
            _ => Results.Ok(new ResponseControllerHubDTO(
              res.Status == HttpStatusCode.OK, res.Data, res.Message))
          };
        })
      .RequireAuthorization()
      .WithName("UpdateHub");

    HubGroup.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete an hub",
          Description = "Deletes an existing hub from the system.")
        ]
    [SwaggerResponse(
          StatusCodes.Status200OK,
          "hub deleted successfully.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "hub not found.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          $"hub cannot be deleted because it has associated stock/items.",
          typeof(ResponseControllerHubDTO))]
    [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteHubDto))]
    [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseHubNotFoundDto))]
    async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          Console.WriteLine($"Deleting hub with ID: {id}");
          var res = await HubService.DeleteHub(id, context, ct);

          // Invalidar cache após exclusão bem-sucedida
          if (res.Status == HttpStatusCode.OK)
          {
            await HubCacheService.InvalidateHubCache(cache, id, null, ct);
          }

          return res.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerHubDTO(
              false, null, res.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerHubDTO(
              false, null, res.Message)),
            _ => Results.Ok(new ResponseControllerHubDTO(res.Status == HttpStatusCode.OK, null, res.Message))
          };
        })
      .RequireAuthorization()
      .WithName("DeleteHub");
  }
}