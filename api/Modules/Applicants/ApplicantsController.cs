using System.Net;
using api.DB;
using api.Modules.Applicants.Dto;
using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.Applicants;

public static class ApplicantsController {
    public static void ApplicantRoutes(this WebApplication app) {
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
        async (RequestCreateApplicantDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await ApplicantService.CreateApplicant(request, context, ct);

            if (response.Status == HttpStatusCode.Conflict) {
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
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await ApplicantService.GetApplicant(id, context, ct);

            if (response.Data == null) {
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
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "No applicants found.",
          typeof(ResponseControllerApplicantsListDTO))]
        async (ApiDbContext context, CancellationToken ct) => {
            var response = await ApplicantService.GetApplicants(context, ct);

            if (response.Data == null) {
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
        async (Guid id, RequestUpdateApplicantDto request, ApiDbContext context, CancellationToken ct) => {
            var response = await ApplicantService.UpdateApplicant(id, request, context, ct);

            if (response.Status != HttpStatusCode.OK) {
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
        async (Guid id, ApiDbContext context, CancellationToken ct) => {
            var response = await ApplicantService.DeleteApplicant(id, context, ct);

            if (response.Status == HttpStatusCode.NotFound) {
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
