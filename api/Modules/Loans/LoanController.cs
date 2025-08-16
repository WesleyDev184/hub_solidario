using System.Net;
using api.DB;
using api.Modules.Auth.Entity;
using api.Modules.Loans.Dto;
using api.Modules.Loans.Dto.ExampleDoc;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Caching.Hybrid;
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
          typeof(ExampleResponseLoanItemOrApplicantNotFoundDto))]
    [SwaggerResponseExample(StatusCodes.Status409Conflict,
            typeof(ExampleResponseItemNotAvailableDto))]
    [SwaggerRequestExample(
          typeof(RequestCreateLoanDto),
          typeof(ExampleRequestCreateLoanDto))]
    async (RequestCreateLoanDto request, UserManager<User> userManager, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var res = await LoanService.CreateLoan(request, context, userManager, ct);

          // Invalidar cache após criação bem-sucedida
          if (res.Status == HttpStatusCode.Created && res.Data != null && res.Data.Item != null)
          {
            await LoanCacheService.InvalidateLoanCache(cache, res.Data!.Id, res.Data.Item.StockId, ct);
          }

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
    async (Guid id, UserManager<User> userManager, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = LoanCacheService.Keys.LoanById(id);

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel =>
            {
              var result = await LoanService.GetLoan(id, context, userManager, cancel);
              return result;
            },
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromMinutes(30),
              LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
            },
            cancellationToken: ct);

          if (cachedResponse.Status == HttpStatusCode.NotFound)
          {
            return Results.NotFound(new ResponseControllerLoanDTO(
              false,
              null,
              cachedResponse.Message));
          }

          return Results.Ok(new ResponseControllerLoanDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Data,
            cachedResponse.Message));
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
    async (UserManager<User> userManager, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = LoanCacheService.Keys.AllLoans;

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel => await LoanService.GetLoans(context, userManager, cancel),
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
            },
            cancellationToken: ct,
            tags: new[] { "loans" }
            );

          return Results.Ok(new ResponseControllerLoanListDTO(
            cachedResponse.Status == HttpStatusCode.OK,
            cachedResponse.Count,
            cachedResponse.Data,
            cachedResponse.Message));
        }).RequireAuthorization()
      .WithName("GetLoans");

    loanGroup.MapGet("/full-data",
    [SwaggerOperation(
      Summary = "Get all loans with full data",
      Description = "Retrieves a list of all loans in the system with full data.")
    ]
    [SwaggerResponse(
      StatusCodes.Status200OK,
      "Loans retrieved successfully.",
      typeof(ResponseControllerLoanListFullDataDTO))]
    [SwaggerResponseExample(
      StatusCodes.Status200OK,
      typeof(ExampleResponseGetAllLoanDto))]
    async (UserManager<User> userManager, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
    {
      var cacheKey = LoanCacheService.Keys.AllLoansFullData;

      // Tentar obter do cache primeiro
      var cachedResponse = await cache.GetOrCreateAsync(
        cacheKey,
        async cancel => await LoanService.GetLoansFullData(context, userManager, cancel),
        options: new HybridCacheEntryOptions
        {
          Expiration = TimeSpan.FromDays(2),
          LocalCacheExpiration = TimeSpan.FromMinutes(5) // padronizado
        },
        cancellationToken: ct,
        tags: new[] { "loans" }
        );

      return Results.Ok(new ResponseControllerLoanListFullDataDTO(
        cachedResponse.Status == HttpStatusCode.OK,
        cachedResponse.Count,
        cachedResponse.Data,
        cachedResponse.Message));
    }).RequireAuthorization()
  .WithName("GetLoansFullData");

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
    async (Guid id, RequestUpdateLoanDto request, ApiDbContext context, UserManager<User> userManager, HybridCache cache, CancellationToken ct) =>

        {
          var res = await LoanService.UpdateLoan(id, request, context, userManager, ct);

          // Invalidar cache após atualização bem-sucedida
          if (res.Status == HttpStatusCode.OK && res.Data != null && res.Data.Item != null)
          {
            await LoanCacheService.InvalidateLoanCache(cache, id, res.Data.Item.StockId, ct);
          }

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
    async (Guid id, ApiDbContext context, HybridCache cache, CancellationToken ct) =>
        {
          var res = await LoanService.DeleteLoan(id, context, ct);

          // Invalidar cache após exclusão bem-sucedida
          if (res.Status == HttpStatusCode.OK)
          {
            await LoanCacheService.InvalidateLoanCache(cache, id, res.StockId, ct);
          }

          return res.Status switch
          {
            HttpStatusCode.NotFound => Results.NotFound(new ResponseControllerLoanDTO(false, null, res.Message)),
            HttpStatusCode.InternalServerError => Results.Json(new ResponseControllerLoanDTO(false, null, res.Message),
              statusCode: (int)res.Status),
            _ => Results.Ok(new ResponseControllerLoanDTO(res.Status == HttpStatusCode.OK, null, res.Message))
          };
        }).RequireAuthorization()
      .WithName("DeleteLoan");
  }
}