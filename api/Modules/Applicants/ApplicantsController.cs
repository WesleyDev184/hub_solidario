using System.Net;
using api.DB;
using api.Modules.Applicants.Dto;

namespace api.Modules.Applicants;

public static class ApplicantsController
{
  public static void ApplicantRoutes(this WebApplication app)
  {
    var group = app.MapGroup("/applicants").WithTags("Applicants");

    group.MapPost("/", async (RequestCreateApplicantDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ApplicantService.CreateApplicant(request, context, ct);

      if (response.Status == HttpStatusCode.Conflict)
      {
        return Results.Conflict(new ResponseControllerApplicantsDTO(
          false,
          null,
          response.Message));
      }

      return Results.Created(
        $"/applicants/{response.Data?.Id}",
        new ResponseControllerApplicantsDTO(
          response.Status == HttpStatusCode.Created,
          response.Data,
          response.Message));
    }).RequireAuthorization();

    group.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ApplicantService.GetApplicant(id, context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerApplicantsDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerApplicantsDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
    }).RequireAuthorization();

    group.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ApplicantService.GetApplicants(context, ct);

      if (response.Data == null)
      {
        return Results.NotFound(new ResponseControllerApplicantsListDTO(
          false,
          0,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerApplicantsListDTO(
        response.Status == HttpStatusCode.OK,
        response.Count,
        response.Data,
        response.Message));
    }).RequireAuthorization();

    group.MapPatch("/{id:guid}", async (Guid id, RequestUpdateApplicantDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ApplicantService.UpdateApplicant(id, request, context, ct);

      if (response.Status != HttpStatusCode.OK)
      {
        return Results.NotFound(new ResponseControllerApplicantsDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerApplicantsDTO(
        response.Status == HttpStatusCode.OK,
        response.Data,
        response.Message));
    }).RequireAuthorization();

    group.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var response = await ApplicantService.DeleteApplicant(id, context, ct);

      if (response.Status == HttpStatusCode.NotFound)
      {
        return Results.NotFound(new ResponseControllerApplicantsDTO(
          false,
          null,
          response.Message));
      }

      return Results.Ok(new ResponseControllerApplicantsDTO(
        response.Status == HttpStatusCode.OK,
        null,
        response.Message));
    }).RequireAuthorization();
  }
}
