using System;
using System.Net;
using api.Auth.Entity;
using api.DB;
using api.Modules.Loans.Dto;
using Microsoft.AspNetCore.Identity;

namespace api.Modules.Loans;

public static class LoanController
{
  public static void LoanRoutes(this WebApplication app)
  {
    var loanGroup = app.MapGroup("loans")
      .WithTags("Loans");

    loanGroup.MapPost("/", async (RequestCreateLoanDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await LoanService.CreateLoan(request, context, ct);

      if (res.Status != HttpStatusCode.Created)
      {
        return Results.BadRequest(new ResponseControllerLoanDTO(
          false,
          null,
          res.Message));
      }

      return Results.Created(
        $"/loans/{res.Data?.Id}",
        new ResponseControllerLoanDTO(
          res.Status == HttpStatusCode.Created,
          res.Data,
          res.Message
        ));
    }).RequireAuthorization()
      .WithName("CreateLoan");

    loanGroup.MapGet("/{id:guid}", async (Guid id, UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await LoanService.GetLoan(id, context, userManager, ct);

      if (res.Data == null)
      {
        return Results.NotFound(new ResponseControllerLoanDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerLoanDTO(
        res.Status == HttpStatusCode.OK,
        res.Data,
        res.Message));
    }).RequireAuthorization()
      .WithName("GetLoan");

    loanGroup.MapGet("/", async (UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await LoanService.GetLoans(context, userManager, ct);

      if (res.Data == null || res.Count == 0)
      {
        return Results.NotFound(new ResponseControllerLoanListDTO(
          false,
          0,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerLoanListDTO(
        res.Status == HttpStatusCode.OK,
        res.Count,
        res.Data,
        res.Message));
    }).RequireAuthorization()
      .WithName("GetLoans");

    loanGroup.MapPatch("/{id:guid}", async (Guid id, RequestUpdateLoanDto request, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await LoanService.UpdateLoan(id, request, context, ct);

      if (res.Status != HttpStatusCode.OK)
      {
        return Results.NotFound(new ResponseControllerLoanDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerLoanDTO(
        res.Status == HttpStatusCode.OK,
        res.Data,
        res.Message));
    }).RequireAuthorization()
      .WithName("UpdateLoan");

    loanGroup.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
    {
      var res = await LoanService.DeleteLoan(id, context, ct);

      if (res.Status != HttpStatusCode.OK)
      {
        return Results.NotFound(new ResponseControllerLoanDTO(
          false,
          null,
          res.Message));
      }

      return Results.Ok(new ResponseControllerLoanDTO(
        res.Status == HttpStatusCode.OK,
        res.Data,
        res.Message));
    }).RequireAuthorization()
      .WithName("DeleteLoan");
  }
}
