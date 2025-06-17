using System;
using System.Net;
using api.DB;
using api.Modules.OrthopedicBanks.Dto;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankController
{
  public static void OrthopedicBankRoutes(this WebApplication app)
  {
    var orthopedicBankGroup = app.MapGroup("orthopedic-banks")
      .WithTags("Orthopedic Banks");

    orthopedicBankGroup.MapPost("/", async (RequestCreateOrthopedicBankDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await OrthopedicBankService.CreateOrthopedicBank(request, context, ct);

      if (res.Data == null)
      {
        return Results.BadRequest(new ResponseControllerOrthopedicBankDTO(
          false,
          null,
          res.Message));
      }

      return Results.Created(
        $"/orthopedic-banks/{res.Data?.Id}",
        new ResponseControllerOrthopedicBankDTO(
          res.Status == HttpStatusCode.Created,
          res.Data,
          res.Message
        ));
    })
    .RequireAuthorization()
    .WithName("CreateOrthopedicBank");

    orthopedicBankGroup.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await OrthopedicBankService.GetOrthopedicBank(id, context, ct);

      if (res.Data == null)
      {
        return Results.NotFound(new ResponseControllerOrthopedicBankDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerOrthopedicBankDTO(
        res.Status == HttpStatusCode.OK,
        res.Data,
        res.Message));
    })
    .RequireAuthorization()
    .WithName("GetOrthopedicBank");

    orthopedicBankGroup.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
    {
      var res = await OrthopedicBankService.GetOrthopedicBanks(context, ct);

      if (res.Data == null || res.Count == 0)
      {
        return Results.NotFound(new ResponseControllerOrthopedicBankListDTO(
          false,
          0,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerOrthopedicBankListDTO(
        res.Status == HttpStatusCode.OK,
        res.Count,
        res.Data,
        res.Message));
    })
    .RequireAuthorization()
    .WithName("GetOrthopedicBanks");

    orthopedicBankGroup.MapPatch("/{id:guid}", async (Guid id, RequestUpdateOrthopedicBankDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await OrthopedicBankService.UpdateOrthopedicBank(id, request, context, ct);

      if (res.Data == null)
      {
        return Results.NotFound(new ResponseControllerOrthopedicBankDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerOrthopedicBankDTO(
        res.Status == HttpStatusCode.OK,
        res.Data,
        res.Message));
    })
    .RequireAuthorization()
    .WithName("UpdateOrthopedicBank");

    orthopedicBankGroup.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      Console.WriteLine($"Deleting orthopedic bank with ID: {id}");
      var res = await OrthopedicBankService.DeleteOrthopedicBank(id, context, ct);

      if (res.Data == null || res.Status == HttpStatusCode.NotFound)
      {
        return Results.NotFound(new ResponseControllerOrthopedicBankDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerOrthopedicBankDTO(
        res.Status == HttpStatusCode.OK,
        null,
        res.Message));
    })
    .RequireAuthorization()
    .WithName("DeleteOrthopedicBank");

  }

}
