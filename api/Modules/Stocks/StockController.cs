using System.Net;
using api.DB;
using api.Modules.Stocks.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Stocks;

public static class StockController {
    public static void StockRoutes(this WebApplication app) {
        var stockGroup = app.MapGroup("stocks")
          .WithTags("Stocks");

        stockGroup.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new stock",
          Description = "Creates a new stock in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status201Created,
          "Stock created successfully.",
          typeof(ResponseControllerStockDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Stock already exists.",
          typeof(ResponseControllerStockDTO))]
        async (RequestCreateStockDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await StockService.CreateStock(request, context, ct);

            if (response.Status == HttpStatusCode.Conflict) {
                return Results.Conflict(new ResponseControllerStockDTO(
              false,
              null,
              response.Message));
            }


            return Results.Created(
          $"/stocks/{response.Data?.Id}",
          new ResponseControllerStockDTO(
            response.Status == HttpStatusCode.Created,
            response.Data,
            response.Message));

        });

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
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await StockService.GetStock(id, context, ct);

            if (response.Data == null) {
                return Results.NotFound(new ResponseControllerStockDTO(
              false,
              null,
              response.Message));
            }

            return Results.Ok(new ResponseControllerStockDTO(
          response.Status == HttpStatusCode.OK,
          response.Data,
          response.Message));
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
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "No stocks found.",
          typeof(ResponseControllerStockDTO))]
        async (ApiDbContext context, CancellationToken ct) => {
            var response = await StockService.GetStocks(context, ct);

            if (response.Data == null || !response.Data.Any()) {
                return Results.NotFound(new ResponseControllerStockDTO(
              false,
              null,
              response.Message));
            }

            return Results.Ok(new ResponseControllerStockListDTO(
          response.Status == HttpStatusCode.OK,
          response.Count,
          response.Data,
          response.Message));
        });

        stockGroup.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update a stock",
          Description = "Updates an existing stock in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Stock updated successfully.",
          typeof(ResponseControllerStockDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Stock not found.",
          typeof(ResponseControllerStockDTO))]
        async (Guid id, RequestUpdateStockDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await StockService.UpdateStock(id, request, context, ct);

            if (response.Data == null) {
                return Results.NotFound(new ResponseControllerStockDTO(
              false,
              null,
              response.Message));
            }

            return Results.Ok(new ResponseControllerStockDTO(
          response.Status == HttpStatusCode.OK,
          response.Data,
          response.Message));
        });

        stockGroup.MapDelete("/{id:guid}",
        [SwaggerOperation(
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
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await StockService.DeleteStock(id, context, ct);

            if (response.Data == null || response.Status == HttpStatusCode.NotFound) {
                return Results.NotFound(new ResponseControllerStockDTO(
              false,
              null,
              response.Message));
            }

            return Results.Ok(new ResponseControllerStockDTO(
          response.Status == HttpStatusCode.OK,
          null,
          response.Message));
        });

    }

}
