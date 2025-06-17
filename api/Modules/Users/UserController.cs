using System.Net;
using api.DB;
using api.Modules.Users.Dto;

namespace api.Modules.Users;

public static class UserController
{
    public static void AddUserRoutes(this WebApplication app)
    {
        var userRoutes = app.MapGroup("user").WithTags("User");

        userRoutes.MapPost("/", async (RequestCreateUserDto request, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await UserService.CreateUser(request, context, ct);

            return Results.Json(
                new ResponseControllerUserDTO(
                    response.Status == HttpStatusCode.Created,
                    null,
                    response.Message
                ),
                statusCode: (int)response.Status
            );
        });

        userRoutes.MapGet("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await UserService.GetUserById(id, context, ct);

            if (response.Data == null)
            {
                return Results.Json(
                    new ResponseControllerUserDTO(false, null, response.Message),
                    statusCode: (int)response.Status
                );
            }

            return Results.Json(
                new ResponseControllerUserDTO(
                    true,
                    new ResponseEntityUserDTO(
                        response.Data.Id,
                        response.Data.Name,
                        response.Data.Email,
                        response.Data.Phone,
                        response.Data.CreatedAt
                    ),
                    response.Message
                ),
                statusCode: (int)response.Status
            );
        });

        userRoutes.MapGet("/", async (ApiDbContext context, CancellationToken ct) =>
        {
            var response = await UserService.GetAllUsers(context, ct);

            return Results.Json(
                new ResponseControllerUserListDTO(
                    response.Status == HttpStatusCode.OK,
                    response.Count,
                    response.Data ?? [],
                    response.Message
                ),
                statusCode: (int)response.Status
            );
        });

        userRoutes.MapPatch("/{id:guid}", async (Guid id, RequestUpdateUserDto request, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await UserService.UpdateUser(id, request, context, ct);

            if (response.Data == null)
            {
                return Results.Json(
                    new ResponseControllerUserDTO(false, null, response.Message),
                    statusCode: (int)response.Status
                );
            }

            return Results.Json(
                new ResponseControllerUserDTO(
                    true,
                    new ResponseEntityUserDTO(
                        response.Data.Id,
                        response.Data.Name,
                        response.Data.Email,
                        response.Data.Phone,
                        response.Data.CreatedAt
                    ),
                    response.Message
                ),
                statusCode: (int)response.Status
            );
        });

        userRoutes.MapDelete("/{id:guid}", async (Guid id, ApiDbContext context, CancellationToken ct) =>
        {
            var response = await UserService.DeleteUser(id, context, ct);

            return Results.Json(
                new ResponseControllerUserDTO(
                    response.Status == HttpStatusCode.NoContent,
                    null,
                    response.Message
                ),
                statusCode: (int)response.Status
            );
        });
    }
}
