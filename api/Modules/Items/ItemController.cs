using System.Net;
using api.DB;
using api.Modules.Items.Dto;
using api.Modules.Items.Dto.ExampleDoc;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Items
{
  public static class ItemController
  {
    public static void ItemRoutes(this WebApplication app)
    {
      RouteGroupBuilder itemGroup = app.MapGroup("items")
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
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Stock not found.",
          typeof(ExampleResponseItemStockNotFoundDTO))]
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseItemNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorItemDTO))]
        [SwaggerRequestExample(
          typeof(RequestCreateItemDto),
          typeof(ExampleRequestCreateItemDto))]
        async (RequestCreateItemDto request, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseItemDTO response = await ItemService.CreateItem(request, context, ct);

          switch (response.Status)
          {
            case HttpStatusCode.Conflict:
              return Results.Conflict(new ResponseControllerItemDTO(
                false,
                null,
                response.Message));
            case HttpStatusCode.BadRequest:
              return Results.BadRequest(new ResponseControllerItemDTO(
                false,
                null,
                response.Message));
            case HttpStatusCode.NotFound:
              return Results.NotFound(new ResponseControllerItemDTO(
                false,
                null,
                response.Message));

            case HttpStatusCode.Created:
              return Results.Created(
                $"/items/{response.Data?.Id}",
                new ResponseControllerItemDTO(
                  true,
                  response.Data,
                  response.Message));
            case HttpStatusCode.InternalServerError:
            default:
              return Results.Json(
                new ResponseControllerItemDTO(
                  false,
                  null,
                  response.Message),
                statusCode: (int)response.Status);
          }
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
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseItemNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetItemDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseItemDTO response = await ItemService.GetItem(id, context, ct);

          if (response.Status == HttpStatusCode.NotFound)
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

      itemGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all items",
          Description = "Retrieves a list of all items in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Items retrieved successfully.",
          typeof(ResponseControllerItemListDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllItemDTO))]
        async (ApiDbContext context, CancellationToken ct) =>
        {
          ResponseItemListDTO response = await ItemService.GetItems(context, ct);

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
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Item already exists.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseItemNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorItemDTO))]
        [SwaggerRequestExample(
          typeof(RequestUpdateItemDto),
          typeof(ExampleRequestUpdateItemDto))]
        async (Guid id, RequestUpdateItemDto request, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseItemDTO response = await ItemService.UpdateItem(id, request, context, ct);

          return response.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerItemDTO(false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(
              new ResponseControllerItemDTO(false, null, response.Message)),
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerItemDTO(false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerItemDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerItemDTO(response.Status == HttpStatusCode.OK, response.Data,
              response.Message))
          };
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
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseItemNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteItemDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorItemDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseItemDTO response = await ItemService.DeleteItem(id, context, ct);

          return response.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerItemDTO(false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerItemDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerItemDTO(response.Status == HttpStatusCode.OK, response.Data,
              response.Message))
          };
        });
    }
  }
}