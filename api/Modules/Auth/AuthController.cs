namespace api.Modules.Auth
{
  using DB;
  using api.Modules.Hubs.Dto;
  using Microsoft.AspNetCore.Authentication.BearerToken;
  using Microsoft.AspNetCore.Http.HttpResults;
  using Microsoft.AspNetCore.Identity;
  using Microsoft.AspNetCore.Mvc;
  using Microsoft.EntityFrameworkCore;
  using Microsoft.Extensions.Caching.Hybrid;
  using Microsoft.OpenApi.Any;
  using Microsoft.OpenApi.Models;
  using Swashbuckle.AspNetCore.Annotations;
  using Swashbuckle.AspNetCore.Filters;
  using api.Modules.Auth.Entity;
  using api.Modules.Auth.Dto;
  using api.Modules.Auth.Dto.ExempleDoc;

  public static class AuthController
  {
    public static void AuthRoutes(this WebApplication app)
    {
      RouteGroupBuilder authRoutes = app.MapGroup("").WithTags("Auth");

      authRoutes.MapPost("/login",
          [SwaggerOperation(
            Summary = "User Login",
            Description = "Logs in a user with email and password. Returns an access token if successful."
          )]
      [SwaggerResponse(200, "Login successful", typeof(AccessTokenResponse))]
      [SwaggerResponse(401, "Invalid credentials or lockout", typeof(ProblemDetails))]
      [SwaggerResponseExample(200, typeof(ExampleResponseLoginUserDTO))]
      [SwaggerResponseExample(401, typeof(ExampleResponseLoginErrorUserDTO))]
      [SwaggerRequestExample(typeof(RequestLoginUserDto), typeof(ExampleRequestLoginUserDTO))]
      async Task<Results<Ok<AccessTokenResponse>, EmptyHttpResult, ProblemHttpResult>> (
            HttpRequest request, SignInManager<User> signInManager, RequestLoginUserDto login) =>
          {
            bool useCookies = request.Query.ContainsKey("useCookies") &&
                              bool.TryParse(request.Query["useCookies"], out bool useCookieValue) &&
                              useCookieValue;
            bool useSessionCookies = request.Query.ContainsKey("useSessionCookies") &&
                                     bool.TryParse(request.Query["useSessionCookies"],
                                       out bool useSessionCookieValue) && useSessionCookieValue;

            bool useCookieScheme = useCookies || useSessionCookies;
            bool isPersistent = useCookies && !useSessionCookies;
            signInManager.AuthenticationScheme = useCookieScheme
              ? IdentityConstants.ApplicationScheme
              : IdentityConstants.BearerScheme;

            Microsoft.AspNetCore.Identity.SignInResult result =
              await signInManager.PasswordSignInAsync(login.Email, login.Password, isPersistent, true);

            if (!result.Succeeded)
            {
              return TypedResults.Problem(result.ToString(),
                statusCode: StatusCodes.Status401Unauthorized);
            }

            // atualizar o token do usuário
            User? user = await signInManager.UserManager.FindByEmailAsync(login.Email);
            if (user == null)
            {
                return TypedResults.Problem("User not found", statusCode: StatusCodes.Status404NotFound);
              }

              // Só atualiza se DeviceToken foi realmente enviado e é diferente do atual
              if (!string.IsNullOrWhiteSpace(login.DeviceToken) && login.DeviceToken != user.DeviceToken)
              {
                user.DeviceToken = login.DeviceToken;
                IdentityResult updateResult = await signInManager.UserManager.UpdateAsync(user);
                if (!updateResult.Succeeded)
                {
                return TypedResults.Problem("Error updating user device token",
                  statusCode: StatusCodes.Status500InternalServerError);
                }
              }

            return TypedResults.Empty;
          })
        .WithOpenApi(operation =>
        {
          operation.Parameters.Add(new OpenApiParameter
          {
            Name = "useCookies",
            In = ParameterLocation.Query,
            Description =
              "Set to true to use persistent cookies for authentication. Mutually exclusive with useSessionCookies.",
            Required = false,
            Schema = new OpenApiSchema { Type = "boolean", Default = new OpenApiBoolean(false) }
          });

          operation.Parameters.Add(new OpenApiParameter
          {
            Name = "useSessionCookies",
            In = ParameterLocation.Query,
            Description =
              "Set to true to use session-only cookies for authentication. Mutually exclusive with useCookies.",
            Required = false,
            Schema = new OpenApiSchema { Type = "boolean", Default = new OpenApiBoolean(false) }
          });

          return operation;
        });

      authRoutes.MapPost("/logout",
        [SwaggerOperation(
          Summary = "User Logout",
          Description =
            "Logs out the currently authenticated user. Invalidates the access token and removes the session."
        )]
      [SwaggerResponse(200, "Logout successful", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseLogoutUserDTO))]
      async (SignInManager<User> signInManager) =>
        {
          await signInManager.SignOutAsync();
          return Results.Ok(new ResponseControllerUserDTO(
            true,
            null,
            "User logged out successfully"
          ));
        });

      authRoutes.MapPost("/user",
        [SwaggerOperation(
          Summary = "Create User",
          Description =
            "Creates a new user with the provided details. Returns the created user ID if successful."
        )]
      [SwaggerResponse(201, "User created successfully", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(400, "Bad Request", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(201, typeof(ExampleResponseCreateUserDTO))]
      [SwaggerResponseExample(400, typeof(ExampleResponseErrorUserDTO))]
      async (UserManager<User> userManager, RequestCreateUserDto newUser, HybridCache cache, CancellationToken ct) =>
        {
          if (string.IsNullOrWhiteSpace(newUser.Email) || string.IsNullOrWhiteSpace(newUser.Password))
          {
            return Results.BadRequest(new ResponseControllerUserDTO(
              false,
              null,
              "Email and Password are required"
            ));
          }

          if (await userManager.FindByEmailAsync(newUser.Email) != null)
          {
            return Results.BadRequest(new ResponseControllerUserDTO(
              false,
              null,
              "User with this email already exists"
            ));
          }

          User user = new()
          {
            UserName = newUser.Email,
            Email = newUser.Email,
            Name = newUser.Name,
            PhoneNumber = newUser.PhoneNumber,
            DeviceToken = newUser.DeviceToken,
            HubId = newUser.HubId
          };

          IdentityResult result = await userManager.CreateAsync(user, newUser.Password);

          if (!result.Succeeded)
          {
            return Results.BadRequest(new ResponseControllerUserDTO(
              false,
              null,
              "Error creating user: " + string.Join(", ", result.Errors.Select(e => e.Description))
            ));
          }

          // Invalidar cache após criação bem-sucedida
          await AuthCacheService.InvalidateAllUserCaches(cache, ct);
          await AuthCacheService.InvalidateHubUserCaches(cache, newUser.HubId, ct);

          return Results.Created($"/user/{user.Id}", new ResponseControllerUserDTO(
            true,
            null,
            "User created successfully"
          ));
        });

      authRoutes.MapGet("/user",
        [SwaggerOperation(
          Summary = "Get Current User",
          Description = "Retrieves the currently authenticated user details."
        )]
      [SwaggerResponse(200, "User retrieved successfully", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseGetUserDTO))]
      [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
      async (UserManager<User> userManager, ApiDbContext api, HttpContext context, HybridCache cache, CancellationToken ct) =>
        {
          var user = await userManager.GetUserAsync(context.User);

          if (user == null)
          {
            return Results.NotFound(new ResponseControllerUserDTO(
              false,
              null,
              "User not found"
            ));
          }

          var cacheKey = AuthCacheService.Keys.UserById(user.Id);

          // Tentar obter do cache primeiro
          var cachedUserData = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel =>
            {
              ResponseEntityHubDTO? hub = await api.Hubs
                .Where(o => o.Id == user.HubId)
                .AsNoTracking()
                .Select(o => new ResponseEntityHubDTO(
                  o.Id,
                  o.Name,
                  o.City,
                  null,
                  o.CreatedAt
                ))
                .FirstOrDefaultAsync(cancel);

              return new ResponseEntityUserDTO(
                user.Id,
                user.Name ?? "",
                user.Email ?? "",
                user.PhoneNumber ?? "",
                user.DeviceToken,
                hub,
                user.CreatedAt
              );
            },
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(5)
            },
            cancellationToken: ct,
            tags: [$"user-{user.HubId}"]);

          return Results.Ok(new ResponseControllerUserDTO(
            true,
            cachedUserData,
            "User retrieved successfully"
          ));
        }).RequireAuthorization();

      authRoutes.MapGet("/users",
        [SwaggerOperation(
          Summary = "Get All Users",
          Description = "Retrieves a list of all users in the system."
        )]
      [SwaggerResponse(200, "Users retrieved successfully", typeof(ResponseControllerUserListDTO))]
      [SwaggerResponse(404, "No users found", typeof(ResponseControllerUserListDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseGetAllUserDTO))]
      [SwaggerResponseExample(404, typeof(ExampleResponseUserListNotFoundDTO))]
      async (UserManager<User> userManager, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = AuthCacheService.Keys.AllUsers;

          // Tentar obter do cache primeiro
          var cachedUsers = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel =>
            {
              List<User> users = await userManager.Users.ToListAsync(cancel);
              return users.Select(u => new ResponseEntityUserDTO(
                u.Id,
                u.Name ?? "",
                u.Email ?? "",
                u.PhoneNumber ?? "",
                u.DeviceToken,
                null,
                u.CreatedAt
              )).ToList();
            },
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(10)
            },
            cancellationToken: ct);

          if (cachedUsers.Count == 0)
          {
            return Results.Ok(new ResponseControllerUserListDTO(
              true,
              0,
              [],
              "No users found"
            ));
          }

          return Results.Ok(new ResponseControllerUserListDTO(
            true,
            cachedUsers.Count,
            cachedUsers,
            "Users retrieved successfully"
          ));
        }).RequireAuthorization();

      authRoutes.MapGet("/user/{id}",
        [SwaggerOperation(
          Summary = "Get User by ID",
          Description = "Retrieves a user by their ID."
        )]
      [SwaggerResponse(200, "User retrieved successfully", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseGetUserDTO))]
      [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
      async (UserManager<User> userManager, ApiDbContext api, Guid id, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = AuthCacheService.Keys.UserById(id);

          // Tentar obter do cache primeiro
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel =>
            {
              User? user = await userManager.FindByIdAsync(id.ToString());
              if (user == null)
              {
                return new { User = (ResponseEntityUserDTO?)null, Found = false };
              }

              ResponseEntityHubDTO? hub = await api.Hubs
                .Where(o => o.Id == user.HubId)
                .AsNoTracking()
                .Select(o => new ResponseEntityHubDTO(
                  o.Id,
                  o.Name,
                  o.City,
                  null,
                  o.CreatedAt
                ))
                .FirstOrDefaultAsync(cancel);

              return new
              {
                User = (ResponseEntityUserDTO?)new ResponseEntityUserDTO(
                  user.Id,
                  user.Name ?? "",
                  user.Email ?? "",
                  user.PhoneNumber ?? "",
                  user.DeviceToken,
                  hub,
                  user.CreatedAt
                ),
                Found = true
              };
            },
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(5)
            },
            cancellationToken: ct);

          if (!cachedResponse.Found)
          {
            return Results.NotFound(new ResponseControllerUserDTO(
              false,
              null,
              "User not found"
            ));
          }

          return Results.Ok(new ResponseControllerUserDTO(
            true,
            cachedResponse.User,
            "User retrieved successfully"
          ));
        }).RequireAuthorization();

      authRoutes.MapPatch("/user",
        [SwaggerOperation(
          Summary = "Update User",
          Description = "Updates the details of the currently authenticated user."
        )]
      [SwaggerResponse(200, "User updated successfully", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(400, "Email already exists", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseUpdateUserDTO))]
      [SwaggerResponseExample(400, typeof(ExampleResponseConflictUserDTO))]
      [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
      [SwaggerRequestExample(typeof(RequestUpdateUserDto), typeof(ExampleRequestUpdateUserDTO))]
      async (UserManager<User> userManager, HttpContext context, ApiDbContext api,
          RequestUpdateUserDto updatedUser, HybridCache cache, CancellationToken ct) =>
        {
          User? user = await userManager.GetUserAsync(context.User);
          if (user == null)
          {
            return Results.NotFound(new ResponseControllerUserDTO(
              false,
              null,
              "User not found"
            ));
          }

          user.Name = updatedUser.Name ?? user.Name;
          user.PhoneNumber = updatedUser.PhoneNumber ?? user.PhoneNumber;

          // validate email already exists
          if (updatedUser.Email != null && updatedUser.Email != user.Email)
          {
            User? existingUser = await userManager.FindByEmailAsync(updatedUser.Email);
            if (existingUser != null)
            {
              return Results.BadRequest(new ResponseControllerUserDTO(
                false,
                null,
                "Email already exists"
              ));
            }

            user.Email = updatedUser.Email;
          }

          user.PasswordHash = updatedUser.Password != null
            ? userManager.PasswordHasher.HashPassword(user, updatedUser.Password)
            : user.PasswordHash;

          IdentityResult result = await userManager.UpdateAsync(user);

          if (!result.Succeeded)
          {
            return Results.NotFound(new ResponseControllerUserDTO(
              false,
              null,
              "User not found" + string.Join(", ", result.Errors.Select(e => e.Description)
              )));
          }

          // Invalidar cache após atualização bem-sucedida
          await AuthCacheService.InvalidateUserCache(cache, user.Id, ct);

          return Results.Ok(new ResponseControllerUserDTO(
            true,
            null,
            "User updated successfully"
          ));
        }).RequireAuthorization();

      authRoutes.MapDelete("/user/{id}",
        [SwaggerOperation(
          Summary = "Delete User",
          Description = "Deletes a user by their ID."
        )]
      [SwaggerResponse(200, "User deleted successfully", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO))]
      [SwaggerResponse(400, "Error deleting user", typeof(ResponseControllerUserDTO))]
      [SwaggerResponseExample(200, typeof(ExampleResponseDeleteUserDTO))]
      [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
      [SwaggerResponseExample(400, typeof(ExampleResponseErrorUserDTO))]
      async (UserManager<User> userManager, Guid id, HybridCache cache, CancellationToken ct) =>
        {
          User? user = await userManager.FindByIdAsync(id.ToString());
          if (user == null)
          {
            return Results.NotFound(new ResponseControllerUserDTO(
              false,
              null,
              "User not found"
            ));
          }

          var userEmail = user.Email;
          var userHubId = user.HubId;

          IdentityResult result = await userManager.DeleteAsync(user);
          if (!result.Succeeded)
          {
            return Results.BadRequest(new ResponseControllerUserDTO(
              false,
              null,
              "Error deleting user: " + string.Join(", ", result.Errors.Select(e => e.Description))
            ));
          }

          // Invalidar cache após exclusão bem-sucedida
          await AuthCacheService.InvalidateUserCache(cache, id, ct);
          if (userHubId.HasValue)
          {
            await AuthCacheService.InvalidateHubUserCaches(cache, userHubId.Value, ct);
          }

          return Results.Ok(new ResponseControllerUserDTO(
            true,
            null,
            "User deleted successfully"
          ));
        }).RequireAuthorization();

      // Endpoint adicional com cache por hub
      authRoutes.MapGet("/users/hub/{hubId:guid}",
        [SwaggerOperation(
          Summary = "Get users by hub",
          Description = "Retrieves all users for a specific hub."
        )]
      [SwaggerResponse(200, "Users retrieved successfully", typeof(ResponseControllerUserListDTO))]
      [SwaggerResponse(404, "hub not found", typeof(ResponseControllerUserListDTO))]
      async (Guid hubId, UserManager<User> userManager, HybridCache cache, CancellationToken ct) =>
        {
          var cacheKey = AuthCacheService.Keys.UsersByHub(hubId);

          // Buscar usuários do hub específico com cache
          var cachedResponse = await cache.GetOrCreateAsync(
            cacheKey,
            async cancel =>
            {
              var users = await userManager.Users
                .Where(u => u.HubId == hubId)
                .Select(u => new ResponseEntityUserDTO(
                  u.Id,
                  u.Name ?? "",
                  u.Email ?? "",
                  u.PhoneNumber ?? "",
                  u.DeviceToken,
                  null, // Não incluir dados do banco ortopédico para evitar referência circular
                  u.CreatedAt))
                .ToListAsync(cancel);

              return users;
            },
            options: new HybridCacheEntryOptions
            {
              Expiration = TimeSpan.FromDays(2),
              LocalCacheExpiration = TimeSpan.FromMinutes(5)
            },
            cancellationToken: ct);

          return Results.Ok(new ResponseControllerUserListDTO(
            true,
            cachedResponse.Count,
            cachedResponse,
            $"Users for hub {hubId} retrieved successfully."
          ));
        }).RequireAuthorization();
    }
  }
}