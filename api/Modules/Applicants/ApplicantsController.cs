namespace api.Modules.Applicants
{
  using System.Net;
  using DB;
  using Dto;
  using Dto.ExempleDoc;
  using Microsoft.Extensions.Caching.Hybrid;
  using Swashbuckle.AspNetCore.Annotations;
  using Swashbuckle.AspNetCore.Filters;

  public static class ApplicantsController
  {
    public static void ApplicantRoutes(this WebApplication app)
    {
      RouteGroupBuilder group = app.MapGroup("/applicants").WithTags("Applicants");

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
      async (RequestCreateApplicantDto request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseApplicantsDTO response = await ApplicantService.CreateApplicant(request, context, ct);

          // Invalidar cache após criação bem-sucedida
          if (response.Status == HttpStatusCode.Created)
          {
            await ApplicantCacheService.InvalidateOnApplicantCreated(cache, request.Email, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerApplicantsDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Created($"/applicants/{response.Data?.Id}",
              new ResponseControllerApplicantsDTO(response.Status == HttpStatusCode.Created, response.Data,
                response.Message))
          };
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
      async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = ApplicantCacheService.Keys.ApplicantById(id);

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await ApplicantService.GetApplicant(id, context, cancel),
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromMinutes(5),
              LocalCacheExpiration = TimeSpan.FromMinutes(2)
            },
            cancellationToken: ct);

          if (cachedResponse.Data == null)
          {
            return Results.NotFound(new ResponseControllerApplicantsDTO(
              false,
              null,
              cachedResponse.Message));
          }

          return Results.Ok(new ResponseControllerApplicantsDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Data,
            cachedResponse.Message));
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
      async (ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = ApplicantCacheService.Keys.AllApplicants;

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await ApplicantService.GetApplicants(context, cancel),
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromMinutes(3),
              LocalCacheExpiration = TimeSpan.FromMinutes(1)
            },
            cancellationToken: ct);

          return Results.Ok(new ResponseControllerApplicantsListDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Count,
            cachedResponse.Data,
            cachedResponse.Message));
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
      async (Guid id, RequestUpdateApplicantDto? request, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseApplicantsDTO response = await ApplicantService.UpdateApplicant(id, request, context, ct);

          // Invalidar cache após atualização bem-sucedida
          if (response.Status == HttpStatusCode.OK)
          {
            await ApplicantCacheService.InvalidateOnApplicantUpdated(cache, id, request?.Email, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.BadRequest => Results.BadRequest(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerApplicantsDTO(false, null, response.Message), statusCode: (int)response.Status),
            HttpStatusCode.Conflict => Results.Conflict(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            _ => Results.Ok(new ResponseControllerApplicantsDTO(response.Status == HttpStatusCode.OK, response.Data,
              response.Message))
          };
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
      async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          ResponseApplicantsDTO response = await ApplicantService.DeleteApplicant(id, context, ct);

          // Invalidar cache após exclusão bem-sucedida
          if (response.Status == HttpStatusCode.OK)
          {
            await ApplicantCacheService.InvalidateOnApplicantDeleted(cache, id, ct);
          }

          return response.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerApplicantsDTO(
              false, null, response.Message)),
            HttpStatusCode.InternalServerError => Results.Json(
              new ResponseControllerApplicantsDTO(false, null, response.Message), statusCode: (int)response.Status),
            _ => Results.Ok(new ResponseControllerApplicantsDTO(response.Status == HttpStatusCode.OK, null,
              response.Message))
          };
        }).RequireAuthorization();
    }
  }
}