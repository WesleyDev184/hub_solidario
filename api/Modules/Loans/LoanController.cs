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
        [SwaggerOperation(
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
        [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseErrorDTO))]
        [SwaggerRequestExample(
          typeof(RequestCreateLoanDto),
          typeof(ExampleRequestCreateLoanDto))]
        async (RequestCreateLoanDto request, ApiDbContext context, CancellationToken ct) =>
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
          typeof(ExampleResponseGetLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDTO))]
        async (Guid id, UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
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

        loanGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all loans",
          Description = "Retrieves a list of all loans in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Loans retrieved successfully.",
          typeof(ResponseControllerLoanListDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "No loans found.",
          typeof(ResponseControllerLoanListDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoansNotFoundDTO))]
        async (UserManager<User> userManager, ApiDbContext context, CancellationToken ct) =>
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

        loanGroup.MapPatch("/{id:guid}",
        [SwaggerOperation(
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
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDTO))]
        [SwaggerRequestExample(
          typeof(RequestUpdateLoanDto),
          typeof(ExampleRequestUpdateLoanDto))]
        async (Guid id, RequestUpdateLoanDto request, ApiDbContext context, CancellationToken ct) =>
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
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteLoanDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseLoanNotFoundDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
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
