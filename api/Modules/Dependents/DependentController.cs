using System.Net;
using api.DB;
using api.Modules.Dependents.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Dependents;

public static class DependentController
{
  public static void DependentRoutes(this WebApplication app)
  {
    var group = app.MapGroup("/dependents").WithTags("Dependents");

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
    async (RequestCreateDependentDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await DependentService.CreateDependent(request, context, ct);

      if (response.Status == HttpStatusCode.Conflict)
      {
        return Results.Conflict(new ResponseControllerDependentDTO(
          false,
          null,
          response.Message));
      }

      return Results.Created(
        $"/Dependents/{response.Data?.Id}",
        new ResponseControllerDependentDTO(
          response.Status == HttpStatusCode.Created,
          response.Data,
          response.Message));
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
    async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await DependentService.GetDependent(id, context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerDependentDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerDependentDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
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
    [SwaggerResponse(
      StatusCodes.Status404NotFound,
      "No dependents found.",
      typeof(ResponseControllerDependentListDTO))]
    async (ApiDbContext context, CancellationToken ct) =>
    {
      var response = await DependentService.GetDependent(context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerDependentListDTO(
          false,
          0,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerDependentListDTO(
        response.Status == HttpStatusCode.OK,
        response.Count,
        response.Data,
        response.Message));
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
    async (Guid id, RequestUpdateDependentDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await DependentService.UpdateDependent(id, request, context, ct);

      if (response.Status != HttpStatusCode.OK)
      {
        return Results.NotFound(new ResponseControllerDependentDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerDependentDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
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
    async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await DependentService.DeleteDependent(id, context, ct);

      if (response.Status == HttpStatusCode.NotFound)
      {
        return Results.NotFound(new ResponseControllerDependentDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerDependentDTO(
        response.Status == HttpStatusCode.OK,
        null,
        response.Message));
    }).RequireAuthorization();
  }

}
