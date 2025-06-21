using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;
using System.Net;
using api.DB;
using api.Modules.OrthopedicBanks.Dto;
using api.Modules.OrthopedicBanks.Dto.ExampleDoc;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankController
{
    public static void OrthopedicBankRoutes(this WebApplication app)
    {
        var orthopedicBankGroup = app.MapGroup("orthopedic-banks")
          .WithTags("Orthopedic Banks");

        orthopedicBankGroup.MapPost("/",
        [SwaggerOperation(
          Summary = "Create a new orthopedic bank",
          Description = "Creates a new orthopedic bank in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status201Created,
          "Orthopedic bank created successfully.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponse(
          StatusCodes.Status400BadRequest,
          "Invalid request data.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status201Created,
            typeof(ExampleResponseCreateOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status400BadRequest,
            typeof(ExampleResponseBadRequestOrthopedicBankDTO))]
        [SwaggerRequestExample(
            typeof(RequestCreateOrthopedicBankDto),
            typeof(ExampleRequestCreateOrthopedicBankDto))]
        async (RequestCreateOrthopedicBankDto request, ApiDbContext context, CancellationToken ct) =>
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

        orthopedicBankGroup.MapGet("/{id:guid}",
        [SwaggerOperation(
          Summary = "Get an orthopedic bank by ID",
          Description = "Retrieves an orthopedic bank from the system by its unique identifier.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Orthopedic bank retrieved successfully.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Orthopedic bank not found.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status200OK,
            typeof(ExampleResponseGetOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status404NotFound,
            typeof(ExampleResponseOrthopedicBankNotFoundDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
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

        orthopedicBankGroup.MapGet("/",
        [SwaggerOperation(
          Summary = "Get all orthopedic banks",
          Description = "Retrieves a list of all orthopedic banks in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Orthopedic banks retrieved successfully.",
          typeof(ResponseControllerOrthopedicBankListDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "No orthopedic banks found.",
          typeof(ResponseControllerOrthopedicBankListDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status200OK,
            typeof(ExampleResponseGetAllOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status404NotFound,
            typeof(ExampleResponseOrthopedicBanksNotFoundDTO))]
        async (ApiDbContext context, CancellationToken ct) =>
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

        orthopedicBankGroup.MapPatch("/{id:guid}",
        [SwaggerOperation(
          Summary = "Update an orthopedic bank",
          Description = "Updates an existing orthopedic bank in the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Orthopedic bank updated successfully.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Orthopedic bank not found.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status200OK,
            typeof(ExampleResponseUpdateOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status404NotFound,
            typeof(ExampleResponseOrthopedicBankNotFoundDTO))]
        [SwaggerRequestExample(
            typeof(RequestUpdateOrthopedicBankDto),
            typeof(ExampleRequestUpdateOrthopedicBankDto))]
        async (Guid id, RequestUpdateOrthopedicBankDto request, ApiDbContext context, CancellationToken ct) =>
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

        orthopedicBankGroup.MapDelete("/{id:guid}",
        [SwaggerOperation(
          Summary = "Delete an orthopedic bank",
          Description = "Deletes an existing orthopedic bank from the system.")
        ]
        [SwaggerResponse(
          StatusCodes.Status200OK,
          "Orthopedic bank deleted successfully.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponse(
          StatusCodes.Status404NotFound,
          "Orthopedic bank not found.",
          typeof(ResponseControllerOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status200OK,
            typeof(ExampleResponseDeleteOrthopedicBankDTO))]
        [SwaggerResponseExample(
            StatusCodes.Status404NotFound,
            typeof(ExampleResponseOrthopedicBankNotFoundDTO))]
        async (Guid id, ApiDbContext context, CancellationToken ct) =>
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
