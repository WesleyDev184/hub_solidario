namespace api.Modules.Applicants;

using System.Net;
using api.DB;
using api.Modules.Applicants.Dto;
using api.Modules.Applicants.Dto.ExempleDoc;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

public static class ApplicantsController
{
    public static void ApplicantRoutes(this WebApplication app)
    {
        var group = app.MapGroup("/applicants").WithTags("Applicants");

        group.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new applicant",
          Description = "Creates a new applicant in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status201Created,
          "Applicant created successfully.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Applicant already exists.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status201Created, typeof(ExampleResponseCreateApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict, typeof(ExampleResponseConflictApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest, typeof(ExampleResponseBadRequestApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError, typeof(ExampleResponseInternalServerErrorApplicantDTO))]
        [SwaggerRequestExample(
          typeof(RequestCreateApplicantDto),
          typeof(ExampleRequestCreateApplicantDTO))]
        async (RequestCreateApplicantDto request, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await ApplicantService.CreateApplicant(request, context, ct);

            if (response.Status == HttpStatusCode.Conflict)
            {
                return Results.Conflict(new ResponseControllerApplicantsDTO(
              false,
              null,
              response.Message));
            }
            if (response.Status == HttpStatusCode.BadRequest)
            {
                return Results.BadRequest(new ResponseControllerApplicantsDTO(
              false,
              null,
              response.Message));
            }

            if (response.Status == HttpStatusCode.InternalServerError)
            {
                return Results.Json(new ResponseControllerApplicantsDTO(
              false,
              null,
              response.Message),
              statusCode: (int)response.Status);
            }

            return Results.Created(
              $"/applicants/{response.Data?.Id}",
              new ResponseControllerApplicantsDTO(
                response.Status == HttpStatusCode.Created,
                response.Data,
                response.Message));
        }).RequireAuthorization();

        group.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get an applicant by ID",
          Description = "Retrieves an applicant from the system by their unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Applicant retrieved successfully.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseGetApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound, typeof(ExampleResponseApplicantNotFoundDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
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

        group.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all applicants",
          Description = "Retrieves a list of all applicants in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Applicants retrieved successfully.",
          typeof(ResponseControllerApplicantsListDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseGetAllApplicantDTO))]
        async (ApiDbContext context, CancellationToken ct) =>
        {
            var response = await ApplicantService.GetApplicants(context, ct);

            return Results.Ok(new ResponseControllerApplicantsListDTO(
              response.Status == HttpStatusCode.OK,
              response.Count,
              response.Data,
              response.Message));
        }).RequireAuthorization();

        group.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update an applicant",
          Description = "Updates an existing applicant's information in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Applicant updated successfully.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Conflict occurred while updating the applicant.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest, typeof(ExampleResponseBadRequestApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError, typeof(ExampleResponseInternalServerErrorApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseUpdateApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound, typeof(ExampleResponseApplicantNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict, typeof(ExampleResponseConflictApplicantDTO))]
        [SwaggerRequestExample(
          typeof(RequestUpdateApplicantDto),
          typeof(ExampleRequestUpdateApplicantDTO))]
        async (Guid id, RequestUpdateApplicantDto request, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await ApplicantService.UpdateApplicant(id, request, context, ct);

            if (response.Status == HttpStatusCode.BadRequest)
            {
                return Results.BadRequest(new ResponseControllerApplicantsDTO(
                  false,
                  null,
                  response.Message));
            }
            if (response.Status == HttpStatusCode.InternalServerError)
            {
                return Results.Json(new ResponseControllerApplicantsDTO(
                  false,
                  null,
                  response.Message),
                  statusCode: (int)response.Status);
            }
            if (response.Status == HttpStatusCode.Conflict)
            {
                return Results.Conflict(new ResponseControllerApplicantsDTO(
                  false,
                  null,
                  response.Message));
            }
            if (response.Status == HttpStatusCode.NotFound)
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

        group.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete an applicant",
          Description = "Deletes an existing applicant from the system by their unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Applicant deleted successfully.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerApplicantsDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK, typeof(ExampleResponseDeleteApplicantDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound, typeof(ExampleResponseApplicantNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError, typeof(ExampleResponseInternalServerErrorApplicantDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await ApplicantService.DeleteApplicant(id, context, ct);

            if (response.Status == HttpStatusCode.NotFound)
            {
                return Results.NotFound(new ResponseControllerApplicantsDTO(
                  false,
                  null,
                  response.Message));
            }

            if (response.Status == HttpStatusCode.InternalServerError)
            {
                return Results.Json(new ResponseControllerApplicantsDTO(
                  false,
                  null,
                  response.Message),
                  statusCode: (int)response.Status);
            }

            return Results.Ok(new ResponseControllerApplicantsDTO(
              response.Status == HttpStatusCode.OK,
              null,
              response.Message));
        }).RequireAuthorization();
    }
}
