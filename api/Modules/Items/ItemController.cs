using System.Net;
using api.DB;
using api.Modules.Items.Dto;

namespace api.Modules.Items;

public static class ItemController
{
  public static void ItemRoutes(this WebApplication app)
  {
    var itemGroup = app.MapGroup("items")
      .WithTags("Items");

    itemGroup.MapPost("/", async (RequestCreateItemDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ItemService.CreateItem(request, context, ct);

      if (response.Status == HttpStatusCode.Conflict)
      {
        return Results.Conflict(new ResponseControllerItemDTO(
          false,
          null,
          response.Message));
      }

      return Results.Created(
        $"/items/{response.Data?.Id}",
        new ResponseControllerItemDTO(
          response.Status == HttpStatusCode.Created,
          response.Data,
          response.Message));
    });

    itemGroup.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ItemService.GetItem(id, context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerItemDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerItemDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
    });

    itemGroup.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ItemService.GetItems(context, ct);

      if (response.Data == null || !response.Data.Any())
      {
        return Results.NotFound(new ResponseControllerItemDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerItemListDTO(
        response.Status == HttpStatusCode.OK,
        response.Count,
        response.Data,
        response.Message));
    });

    itemGroup.MapPatch("/{id:guid}", async (Guid id, RequestUpdateItemDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ItemService.UpdateItem(id, request, context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerItemDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerItemDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
    });

    itemGroup.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ItemService.DeleteItem(id, context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerItemDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerItemDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
    });

  }

}
