using System.Net;
using api.DB;
using api.Modules.Dependents.Dto;
using api.Modules.Dependents.Dto.ExampleDoc;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Dependents
{
  public static class DependentController
  {
    public static void DependentRoutes(this WebApplication app)
    {
      RouteGroupBuilder group = app.MapGroup("/dependents").WithTags("Dependents");

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
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Applicant not found.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponse(StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status201Created,
          typeof(ExampleResponseCreateDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestDependentDTO))]
        [SwaggerResponseExample(StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentApplicantNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
        [SwaggerRequestExample(
          typeof(RequestCreateDependentDto),
          typeof(ExampleRequestCreateDependentDto))]
        async (RequestCreateDependentDto request, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.CreateDependent(request, context, ct);

          return response.Status switch
          {
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Created($"/Dependents/{response.Data?.Id}",
              new ResponseControllerDependentDTO(response.Status == HttpStatusCode.Created, response.Data,
                response.Message))
          };
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
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetDependentDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.GetDependent(id, context, ct);

          if (response.Status == HttpStatusCode.NotFound)
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
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseGetAllDependentDTO))]
        async (ApiDbContext context, CancellationToken ct) =>
        {
          ResponseDependentListDTO response = await DependentService.GetDependents(context, ct);

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
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponse(
          StatusCodes.Status409Conflict,
          "Conflict error occurred.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status409Conflict,
          typeof(ExampleResponseConflictDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status400BadRequest,
          typeof(ExampleResponseBadRequestDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentOrApplicantNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseUpdateDependentDTO))]
        [SwaggerRequestExample(
          typeof(RequestUpdateDependentDto),
          typeof(ExampleRequestUpdateDependentDto))]
        async (Guid id, RequestUpdateDependentDto request, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.UpdateDependent(id, request, context, ct);

          return response.Status switch
          {
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerDependentDTO(response.Status == HttpStatusCode.OK, response.Data,
              response.Message))
          };
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
        [SwaggerResponse(
          StatusCodes.Status500InternalServerError,
          "An unexpected error occurred.",
          typeof(ResponseControllerDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status404NotFound,
          typeof(ExampleResponseDependentNotFoundDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status200OK,
          typeof(ExampleResponseDeleteDependentDTO))]
        [SwaggerResponseExample(
          StatusCodes.Status500InternalServerError,
          typeof(ExampleResponseInternalServerErrorDependentDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
          ResponseDependentDTO response = await DependentService.DeleteDependent(id, context, ct);

          return response.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerDependentDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerDependentDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerDependentDTO(response.Status == HttpStatusCode.OK, null,
              response.Message))
          };
        }).RequireAuthorization();
    }
  }
}