using System.Net;
using api.Auth.Entity;
using api.DB;
using api.Modules.Loans.Dto;
using api.Modules.Loans.Dto.ExampleDoc;
using Microsoft.AspNetCore.Identity;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Loans;

public static class LoanController
{
  public static void LoanRoutes(this WebApplication app)
  {
    var loanGroup = app.MapGroup("loans")
      .WithTags("Loans");

    loanGroup.MapPost("/",
        [
          SwaggerOperation(
            Summary = "Create a new loan",
            Description = "Creates a new loan in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status201Created,
          "Loan created successfully.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(StatusCodes.Status404NotFound,
          "Item or Applicant not found.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An error occurred while processing the request.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(StatusCodes.Status409Conflict,
          "Item is not available for loan",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseErrorDto))]
        [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateLoanDto))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseErrorDto))]
        [SwaggerResponseExample(StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDto))]
        [
          SwaggerResponseExample(StatusCodes.Status409Conflict,
            typeof(ExampleResponseItemNotAvailableDto))]
        [SwaggerRequestExample(
          typeof(RequestCreateLoanDto),
          typeof(ExampleRequestCreateLoanDto))]
        async (RequestCreateLoanDto request, ApiDbContext context, CancellationToken ct) =>

        {
          var res = await LoanService.CreateLoan(request, context, ct);

          return res.Status switch
          {
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Json(new ResponseControllerLoanDTO(false, null, res.Message),
              statusCode: (int)res.Status),
            _ => Results.Created($"/loans/{res.Data?.Id}",
              new ResponseControllerLoanDTO(res.Status == HttpStatusCode.Created, res.Data, res.Message))
          };
        }).RequireAuthorization()
      .WithName("CreateLoan");

    loanGroup.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get a loan by ID",
          Description = "Retrieves a loan from the system by its unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Loan retrieved successfully.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Loan not found.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetLoanDto))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDto))]
        async (Guid id, UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
        {
          var res = await LoanService.GetLoan(id, context, userManager, ct);

          if (res.Status == HttpStatusCode.NotFound)
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

    loanGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all loans",
          Description = "Retrieves a list of all loans in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Loans retrieved successfully.",
          typeof(ResponseControllerLoanListDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllLoanDto))]
        async (UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
        {
          var res = await LoanService.GetLoans(context, userManager, ct);

          return Results.Ok(new ResponseControllerLoanListDTO(
            res.Status == HttpStatusCode.OK,
            res.Count,
            res.Data,
            res.Message));
        }).RequireAuthorization()
      .WithName("GetLoans");

    loanGroup.MapPatch("/{id:guid}",
        [
          SwaggerOperation(
            Summary = "Update an existing loan",
            Description = "Updates the details of an existing loan in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Loan updated successfully.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Loan not found.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An error occurred while processing the request.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseErrorDto))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseErrorDto))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateLoanDto))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDto))]
        [SwaggerRequestExample(
          typeof(RequestUpdateLoanDto),
          typeof(ExampleRequestUpdateLoanDto))]
        async (Guid id, RequestUpdateLoanDto request, ApiDbContext context, CancellationToken ct) =>

        {
          var res = await LoanService.UpdateLoan(id, request, context, ct);

          return res.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Json(new ResponseControllerLoanDTO(false, null, res.Message),
              statusCode: (int)res.Status),
            _ => Results.Ok(new ResponseControllerLoanDTO(res.Status == HttpStatusCode.OK, res.Data, res.Message))
          };
        }).RequireAuthorization()
      .WithName("UpdateLoan");

    loanGroup.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete a loan",
          Description = "Deletes a loan from the system by its unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Loan deleted successfully.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Loan not found.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An error occurred while processing the request.",
          typeof(ResponseControllerLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteLoanDto))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseErrorDto))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDto))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
          var res = await LoanService.DeleteLoan(id, context, ct);

          return res.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Json(new ResponseControllerLoanDTO(false, null, res.Message),
              statusCode: (int)res.Status),
            _ => Results.Ok(new ResponseControllerLoanDTO(res.Status == HttpStatusCode.OK, res.Data, res.Message))
          };
        }).RequireAuthorization()
      .WithName("DeleteLoan");
  }
}