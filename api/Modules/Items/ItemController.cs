using System.Net;
using api.DB;
using api.Modules.Items.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Items;

public static class ItemController {
    public static void ItemRoutes(this WebApplication app) {
        var itemGroup = app.MapGroup("items")
          .WithTags("Items");

        itemGroup.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new item",
          Description = "Creates a new item in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status201Created,
          "Item created successfully.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Item already exists.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerItemDTO))]
        async (RequestCreateItemDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await ItemService.CreateItem(request, context, ct);

            if (response.Status == HttpStatusCode.Conflict) {
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

        itemGroup.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get an item by ID",
          Description = "Retrieves an item from the system by its unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Item retrieved successfully.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Item not found.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid ID format.",
          typeof(ResponseControllerItemDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await ItemService.GetItem(id, context, ct);

            if (response.Data == null) {
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

        itemGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all items",
          Description = "Retrieves a list of all items in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Items retrieved successfully.",
          typeof(ResponseControllerItemListDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "No items found.",
          typeof(ResponseControllerItemDTO))]
        async (ApiDbContext context, CancellationToken ct) => {
            var response = await ItemService.GetItems(context, ct);

            if (response.Data == null) {
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

        itemGroup.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update an existing item",
          Description = "Updates the details of an existing item in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Item updated successfully.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Item not found.",
          typeof(ResponseControllerItemDTO))]
        async (Guid id, RequestUpdateItemDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await ItemService.UpdateItem(id, request, context, ct);

            if (response.Data == null) {
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

        itemGroup.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete an item",
          Description = "Deletes an item from the system by its unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Item deleted successfully.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Item not found.",
          typeof(ResponseControllerItemDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await ItemService.DeleteItem(id, context, ct);

            if (response.Data == null) {
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
