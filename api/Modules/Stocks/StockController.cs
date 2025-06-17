using System.Net;
using api.DB;
using api.Modules.Stocks.Dto;

namespace api.Modules.Stocks;

public static class StockController
{
  public static void StockRoutes(this WebApplication app)
  {
    var stockGroup = app.MapGroup("stocks")
      .WithTags("Stocks");

    stockGroup.MapPost("/", async (RequestCreateStockDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await StockService.CreateStock(request, context, ct);

      if (response.Status == HttpStatusCode.Conflict)
      {
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

    stockGroup.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await StockService.GetStock(id, context, ct);

      if (response.Data == null)
      {
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

    stockGroup.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
    {
      var response = await StockService.GetStocks(context, ct);

      if (response.Data == null || !response.Data.Any())
      {
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

    stockGroup.MapPatch("/{id:guid}", async (Guid id, RequestUpdateStockDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await StockService.UpdateStock(id, request, context, ct);

      if (response.Data == null)
      {
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

    stockGroup.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await StockService.DeleteStock(id, context, ct);

      if (response.Data == null || response.Status == HttpStatusCode.NotFound)
      {
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
