using System.Net;
using api.DB;
using api.Modules.Stocks.Dto;
using api.Modules.Stocks.Dto.ExampleDoc;
using api.Services.S3;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Hybrid;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Stocks;

public static class StockController
{
  public static void StockRoutes(this WebApplication app)
  {
    var stockGroup = app.MapGroup("stocks")
      .WithTags("Stocks");

    stockGroup.MapPost("/",
      [
        SwaggerOperation(
          Summary = "Create a new stock",
          Description = "Creates a new stock in the system. This endpoint accepts form-data with the following fields: Title (required), HubId (required), and ImageFile (optional).")
      ]
    [SwaggerResponse(
        StatusCodes.Status201Created,
        "Stock created successfully.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status409Conflict,
        "Stock already exists.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status400BadRequest,
        "Invalid request data.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status500InternalServerError,
        "An unexpected error occurred.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(StatusCodes.Status404NotFound,
        $"hub with ID not found.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status201Created,
        typeof(ExampleResponseCreateStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status409Conflict,
        typeof(ExampleResponseConflictStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status400BadRequest,
        typeof(ExampleResponseBadRequestStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status500InternalServerError,
        typeof(ExampleResponseInternalServerErrorStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status404NotFound,
        typeof(ExampleResponseStockHubNotFoundDTO))]
    [SwaggerRequestExample(
        typeof(RequestCreateStockFormDto),
        typeof(ExampleRequestCreateStockFormDto))]
    async ([FromForm] RequestCreateStockFormDto formRequest, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>
      {
        // Converter o form DTO para o DTO original
        var request = new RequestCreateStockDto(
          formRequest.Title,
          formRequest.ImageFile,
          formRequest.HubId
        );

        var response = await StockService.CreateStock(request, context, fileStorageService, ct);

        // Invalidar cache após criação bem-sucedida
        if (response.Status == HttpStatusCode.Created)
        {
          await StockCacheService.InvalidateStockCache(cache, response.Data!.Id, response.Data.HubId, ct);
        }

        return response.Status switch
        {
          HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.BadRequest =>
            Results.BadRequest(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.InternalServerError => Results.Json(
            new ResponseControllerStockDTO(false, null, response.Message), statusCode: (int)response.Status),
          _ => Results.Created($"/stocks/{response.Data?.Id}",
            new ResponseControllerStockDTO(response.Status == HttpStatusCode.Created, response.Data, response.Message))
        };
      }).DisableAntiforgery();

    stockGroup.MapGet("/{id:guid}",
      [SwaggerOperation(
        Summary = "Get a stock by ID",
        Description = "Retrieves a stock from the system by its unique identifier.")
      ]
    [SwaggerResponse(
        StatusCodes.Status200OK,
        "Stock retrieved successfully.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status404NotFound,
        "Stock not found.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status200OK,
        typeof(ExampleResponseGetStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status404NotFound,
        typeof(ExampleResponseStockNotFoundDTO))]
    async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        var cacheKey = StockCacheService.Keys.StockById(id);

        // Tentar obter do cache primeiro
        var cachedResponse = await cache.GetOrCreateAsync(
          cacheKey,
          async cancel => await StockService.GetStock(id, context, cancel),
          options: new HybridCacheEntryOptions
          {
            Expiration = TimeSpan.FromDays(2),
            LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
          },
          cancellationToken: ct);

        if (cachedResponse.Status == HttpStatusCode.NotFound)
        {
          return Results.NotFound(new ResponseControllerStockDTO(
            false,
            null,
            cachedResponse.Message));
        }

        return Results.Ok(new ResponseControllerStockDTO(
          cachedResponse.Status == HttpStatusCode.OK,
          cachedResponse.Data,
          cachedResponse.Message));
      });

    stockGroup.MapGet("/",
      [SwaggerOperation(
        Summary = "Get all stocks",
        Description = "Retrieves all stocks from the system.")
      ]
    [SwaggerResponse(
        StatusCodes.Status200OK,
        "Stocks retrieved successfully.",
        typeof(ResponseControllerStockListDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status200OK,
        typeof(ExampleResponseGetAllStocksDTO))]
    async (ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        var cacheKey = StockCacheService.Keys.AllStocks;

        // Tentar obter do cache primeiro
        var cachedResponse = await cache.GetOrCreateAsync(
          cacheKey,
          async cancel => await StockService.GetStocks(context, cancel),
          options: new HybridCacheEntryOptions
          {
            Expiration = TimeSpan.FromDays(2),
            LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
          },
          cancellationToken: ct,
          tags: ["stocks"]);

        return Results.Ok(new ResponseControllerStockListDTO(
          cachedResponse.Status == HttpStatusCode.OK,
          cachedResponse.Count,
          cachedResponse.Data,
          cachedResponse.Message));
      });

    stockGroup.MapPatch("/{id:guid}",
      [SwaggerOperation(
        Summary = "Update a stock",
        Description = "Updates an existing stock in the system. This endpoint accepts form-data with the following optional fields: Title, ImageFile, MaintenanceQtd, AvailableQtd, and BorrowedQtd.")
      ]
    [SwaggerResponse(
        StatusCodes.Status200OK,
        "Stock updated successfully.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status404NotFound,
        "Stock not found.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status400BadRequest,
        "Invalid request data.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status500InternalServerError,
        "An unexpected error occurred.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(StatusCodes.Status409Conflict,
        "Stock already exists.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status200OK,
        typeof(ExampleResponseUpdateStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status404NotFound,
        typeof(ExampleResponseStockNotFoundDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status400BadRequest,
        typeof(ExampleResponseBadRequestStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status500InternalServerError,
        typeof(ExampleResponseInternalServerErrorStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status409Conflict,
        typeof(ExampleResponseConflictStockDTO))]
    [SwaggerRequestExample(
        typeof(RequestUpdateStockFormDto),
        typeof(ExampleRequestUpdateStockFormDto))]
    async (Guid id, [FromForm] RequestUpdateStockFormDto formRequest, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>
      {
        // Converter o form DTO para o DTO original
        var request = new RequestUpdateStockDto(
          formRequest.Title,
          formRequest.ImageFile,
          formRequest.MaintenanceQtd,
          formRequest.AvailableQtd,
          formRequest.BorrowedQtd
        );

        var response = await StockService.UpdateStock(id, request, context, fileStorageService, ct);

        // Invalidar cache após atualização bem-sucedida
        if (response.Status == HttpStatusCode.OK)
        {
          await StockCacheService.InvalidateStockCache(cache, id, response.Data!.HubId, ct);
        }

        return response.Status switch
        {
          HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.BadRequest =>
            Results.BadRequest(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.InternalServerError => Results.Json(
            new ResponseControllerStockDTO(false, null, response.Message), statusCode: (int)response.Status),
          _ => Results.Ok(new ResponseControllerStockDTO(response.Status == HttpStatusCode.OK, response.Data,
            response.Message))
        };
      }).DisableAntiforgery();

    stockGroup.MapDelete("/{id:guid}",
      [
        SwaggerOperation(
          Summary = "Delete a stock",
          Description = "Deletes an existing stock from the system.")
      ]
    [SwaggerResponse(
        StatusCodes.Status200OK,
        "Stock deleted successfully.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(
        StatusCodes.Status404NotFound,
        "Stock not found.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(StatusCodes.Status400BadRequest,
        "Invalid request data.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponse(StatusCodes.Status500InternalServerError,
        "An unexpected error occurred.",
        typeof(ResponseControllerStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status200OK,
        typeof(ExampleResponseDeleteStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status400BadRequest,
        typeof(ExampleResponseBadRequestStockDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status404NotFound,
        typeof(ExampleResponseStockNotFoundDTO))]
    [SwaggerResponseExample(
        StatusCodes.Status500InternalServerError,
        typeof(ExampleResponseInternalServerErrorStockDTO))]
    async (Guid id, ApiDbContext context, IFileStorageService fileStorageService, HybridCache cache, CancellationToken ct) =>

      {
        var response = await StockService.DeleteStock(id, context, fileStorageService, ct);

        // Invalidar cache após exclusão bem-sucedida
        if (response.Status == HttpStatusCode.OK)
        {
          await StockCacheService.InvalidateStockCache(cache, id, response.HubId, ct);
        }

        return response.Status switch
        {
          HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.BadRequest =>
            Results.BadRequest(new ResponseControllerStockDTO(false, null, response.Message)),
          HttpStatusCode.InternalServerError => Results.Json(
            new ResponseControllerStockDTO(false, null, response.Message), statusCode: (int)response.Status),
          _ => Results.Ok(new ResponseControllerStockDTO(response.Status == HttpStatusCode.OK, null, response.Message))
        };
      });

    // Endpoint adicional com cache por banco ortopédico (opcional)
    stockGroup.MapGet("/hub/{HubId:guid}",
      [SwaggerOperation(
        Summary = "Get stocks by hub",
        Description = "Retrieves all stocks for a specific hub.")
      ]
    [SwaggerResponse(
        StatusCodes.Status200OK,
        "Stocks retrieved successfully.",
        typeof(ResponseControllerStockListDTO))]
    [SwaggerResponse(
        StatusCodes.Status404NotFound,
        "hub not found.",
        typeof(ResponseControllerStockListDTO))]
    async (Guid HubId, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
      {
        var cacheKey = StockCacheService.Keys.StocksByHub(HubId);

        // Buscar stocks do banco ortopédico específico com cache
        var cachedResponse = await cache.GetOrCreateAsync(
          cacheKey,
          async cancel => await StockService.GetStocksByHub(HubId, context, cancel),
          options: new HybridCacheEntryOptions
          {
            Expiration = TimeSpan.FromMinutes(5),
            LocalCacheExpiration = TimeSpan.FromMinutes(2)
          },
          cancellationToken: ct, tags: ["stocks"]);

        if (cachedResponse.Status == HttpStatusCode.NotFound)
        {
          return Results.NotFound(new ResponseControllerStockListDTO(
            false,
            0,
            null,
            cachedResponse.Message));
        }

        return Results.Ok(new ResponseControllerStockListDTO(
          cachedResponse.Status == HttpStatusCode.OK,
          cachedResponse.Count,
          cachedResponse.Data,
          cachedResponse.Message));
      });
  }
}