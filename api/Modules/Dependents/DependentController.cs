using System;
using System.Net;
using api.DB;
using api.Modules.Dependents.Dto;

namespace api.Modules.Dependents;

public static class DependentController
{

  public static void DependentRoutes(this WebApplication app)
  {
    var group = app.MapGroup("/dependents").WithTags("Dependents");

    group.MapPost("/", async (RequestCreateDependentDto request, ApiDbContext context, CancellationToken ct) =>
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

    group.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
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

    group.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
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

    group.MapPatch("/{id:guid}", async (Guid id, RequestUpdateDependentDto request, ApiDbContext context, CancellationToken ct) =>
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

    group.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
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
