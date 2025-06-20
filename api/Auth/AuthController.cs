using api.Auth.Dto;
using api.Auth.Dto.ExempleDoc;
using api.Auth.Entity;
using api.DB;
using api.Modules.OrthopedicBanks.Dto;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Annotations;
using Swashbuckle.AspNetCore.Filters;

namespace api.Auth;

public static class AuthController {

  public static void AuthRoutes(this WebApplication app) {
    var authRoutes = app.MapGroup("").WithTags("Auth");

    authRoutes.MapPost("/login",
    [SwaggerOperation(
        Summary = "User Login",
        Description = "Logs in a user with email and password. Returns an access token if successful."
    )]
    [SwaggerResponse(200, "Login successful", typeof(AccessTokenResponse))]
    [SwaggerResponse(401, "Invalid credentials or lockout", typeof(ProblemDetails))]
    [SwaggerResponseExample(200, typeof(ExampleResponseLoginUserDTO)),]
    [SwaggerResponseExample(401, typeof(ExampleResponseLoginErrorUserDTO))]
    [SwaggerRequestExample(typeof(RequestLoginUserDto), typeof(ExampleRequestLoginUserDTO))]
    async Task<Results<Ok<AccessTokenResponse>, EmptyHttpResult, ProblemHttpResult>> (HttpRequest request, SignInManager<User> signInManager, RequestLoginUserDto login) => {
      var useCookies = request.Query.ContainsKey("useCookies") && bool.TryParse(request.Query["useCookies"], out var useCookieValue) && useCookieValue;
      var useSessionCookies = request.Query.ContainsKey("useSessionCookies") && bool.TryParse(request.Query["useSessionCookies"], out var useSessionCookieValue) && useSessionCookieValue;

      var useCookieScheme = (useCookies == true) || (useSessionCookies == true);
      var isPersistent = (useCookies == true) && (useSessionCookies != true);
      signInManager.AuthenticationScheme = useCookieScheme ? IdentityConstants.ApplicationScheme : IdentityConstants.BearerScheme;

      var result = await signInManager.PasswordSignInAsync(login.Email, login.Password, isPersistent, lockoutOnFailure: true);

      if (!result.Succeeded) {
        return TypedResults.Problem(result.ToString(), statusCode: StatusCodes.Status401Unauthorized);
      }

      return TypedResults.Empty;
    })
    .WithOpenApi(operation => {
      operation.Parameters.Add(new OpenApiParameter {
        Name = "useCookies",
        In = ParameterLocation.Query,
        Description = "Set to true to use persistent cookies for authentication. Mutually exclusive with useSessionCookies.",
        Required = false,
        Schema = new OpenApiSchema { Type = "boolean", Default = new OpenApiBoolean(false) }
      });

      operation.Parameters.Add(new OpenApiParameter {
        Name = "useSessionCookies",
        In = ParameterLocation.Query,
        Description = "Set to true to use session-only cookies for authentication. Mutually exclusive with useCookies.",
        Required = false,
        Schema = new OpenApiSchema { Type = "boolean", Default = new OpenApiBoolean(false) }
      });

      return operation;
    });

    authRoutes.MapPost("/logout",
    [SwaggerOperation(
        Summary = "User Logout",
        Description = "Logs out the currently authenticated user. Invalidates the access token and removes the session."
    )]
    [SwaggerResponse(200, "Logout successful", typeof(ResponseControllerUserDTO))]
    [SwaggerResponseExample(200, typeof(ExampleResponseLogoutUserDTO))]
    async (SignInManager<User> signInManager) => {
      await signInManager.SignOutAsync();
      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: null,
        Message: "User logged out successfully"
      ));
    });

    authRoutes.MapPost("/user",
    [SwaggerOperation(
        Summary = "Create User",
        Description = "Creates a new user with the provided details. Returns the created user ID if successful."
    )]
    [SwaggerResponse(201, "User created successfully", typeof(ResponseControllerUserDTO))]
    [SwaggerResponse(400, "Bad Request", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponseExample(201, typeof(ExampleResponseCreateUserDTO)),]
    [SwaggerResponseExample(400, typeof(ExampleResponseErrorUserDTO))]
    async (UserManager<User> userManager, RequestCreateUserDto newUser) => {
      if (string.IsNullOrWhiteSpace(newUser.Email) || string.IsNullOrWhiteSpace(newUser.Password)) {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "Email and Password are required"
        ));
      }

      if (await userManager.FindByEmailAsync(newUser.Email) != null) {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "User with this email already exists"
        ));
      }

      var user = new User {
        UserName = newUser.Email,
        Email = newUser.Email,
        Name = newUser.Name,
        PhoneNumber = newUser.PhoneNumber,
        OrthopedicBankId = newUser.OrthopedicBankId,
      };

      var result = await userManager.CreateAsync(user, newUser.Password);

      if (!result.Succeeded) {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "Error creating user: " + string.Join(", ", result.Errors.Select(e => e.Description))
        ));
      }

      return Results.Created($"/user/{user.Id}", new ResponseControllerUserDTO(
        Success: true,
        Data: null,
        Message: "User created successfully"
      ));
    });

    authRoutes.MapGet("/user",
    [SwaggerOperation(
        Summary = "Get Current User",
        Description = "Retrieves the currently authenticated user details."
    )]
    [SwaggerResponse(200, "User retrieved successfully", typeof(ResponseControllerUserDTO))]
    [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponseExample(200, typeof(ExampleResponseGetUserDTO)),]
    [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
    async (UserManager<User> userManager, ApiDbContext api, HttpContext context) => {
      var user = await userManager.GetUserAsync(context.User);
      if (user == null) {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }

      var orthopedicBank = await api.OrthopedicBanks
        .Where(o => o.Id == user.OrthopedicBankId)
        .AsNoTracking()
        .Select(o => new ResponseEntityOrthopedicBankDTO(
          o.Id,
          o.Name ?? "",
          o.City ?? "",
          o.CreatedAt
        ))
        .FirstOrDefaultAsync();

      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          OrthopedicBank: orthopedicBank,
          CreatedAt: user.CreatedAt
        ),
        Message: "User retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapGet("/users",
    [SwaggerOperation(
        Summary = "Get All Users",
        Description = "Retrieves a list of all users in the system."
    )]
    [SwaggerResponse(200, "Users retrieved successfully", typeof(ResponseControllerUserListDTO)),]
    [SwaggerResponse(404, "No users found", typeof(ResponseControllerUserListDTO)),]
    [SwaggerResponseExample(200, typeof(ExampleResponseGetAllUserDTO)),]
    [SwaggerResponseExample(404, typeof(ExampleResponseUserListNotFoundDTO))]
    async (UserManager<User> userManager) => {
      var users = await userManager.Users.ToListAsync();
      if (users == null || users.Count == 0) {
        return Results.Ok(new ResponseControllerUserListDTO(
          Success: true,
          Count: 0,
          Data: [],
          Message: "No users found"
        ));
      }

      return Results.Ok(new ResponseControllerUserListDTO(
        Success: true,
        Count: users.Count,
        Data: [.. users.Select(u => new ResponseEntityUserDTO(
          Id: u.Id,
          Name: u.Name ?? "",
          Email: u.Email ?? "",
          PhoneNumber: u.PhoneNumber ?? "",
          OrthopedicBank:null,
          CreatedAt: u.CreatedAt
        ))],
        Message: "Users retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapGet("/user/{id}",
    [SwaggerOperation(
        Summary = "Get User by ID",
        Description = "Retrieves a user by their ID."
    )]
    [SwaggerResponse(200, "User retrieved successfully", typeof(ResponseControllerUserDTO))]
    [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponseExample(200, typeof(ExampleResponseGetUserDTO)),]
    [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
    async (UserManager<User> userManager, ApiDbContext api, string id) => {
      var user = await userManager.FindByIdAsync(id);
      if (user == null) {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }

      var orthopedicBank = await api.OrthopedicBanks
          .Where(o => o.Id == user.OrthopedicBankId)
          .AsNoTracking()
          .Select(o => new ResponseEntityOrthopedicBankDTO(
            o.Id,
            o.Name ?? "",
            o.City ?? "",
            o.CreatedAt
          ))
          .FirstOrDefaultAsync();

      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          OrthopedicBank: orthopedicBank,
          CreatedAt: user.CreatedAt
        ),
        Message: "User retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapPatch("/user",
    [SwaggerOperation(
        Summary = "Update User",
        Description = "Updates the details of the currently authenticated user."
    )]
    [SwaggerResponse(200, "User updated successfully", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponse(400, "Email already exists", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponseExample(200, typeof(ExampleResponseUpdateUserDTO)),]
    [SwaggerResponseExample(400, typeof(ExampleResponseConflictUserDTO)),]
    [SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO))]
    [SwaggerRequestExample(typeof(RequestUpdateUserDto), typeof(ExampleRequestUpdateUserDTO))]
    async (UserManager<User> userManager, HttpContext context, ApiDbContext api, RequestUpdateUserDto updatedUser) => {
      var user = await userManager.GetUserAsync(context.User);
      if (user == null) {
        return Results.NotFound(new ResponseControllerUserDTO(
                Success: false,
                Data: null,
                Message: "User not found"
            ));
      }

      user.Name = updatedUser.Name ?? user.Name;
      user.PhoneNumber = updatedUser.PhoneNumber ?? user.PhoneNumber;

      // validate email already exists
      if (updatedUser.Email != null && updatedUser.Email != user.Email) {
        var existingUser = await userManager.FindByEmailAsync(updatedUser.Email);
        if (existingUser != null) {
          return Results.BadRequest(new ResponseControllerUserDTO(
            Success: false,
            Data: null,
            Message: "Email already exists"
          ));
        }
        user.Email = updatedUser.Email;
      }

      user.PasswordHash = updatedUser.Password != null
        ? userManager.PasswordHasher.HashPassword(user, updatedUser.Password)
        : user.PasswordHash;

      var result = await userManager.UpdateAsync(user);

      if (!result.Succeeded) {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found" + string.Join(", ", result.Errors.Select(e => e.Description)
      )));
      }

      var orthopedicBank = await api.OrthopedicBanks
        .Where(o => o.Id == user.OrthopedicBankId)
        .AsNoTracking()
        .Select(o => new ResponseEntityOrthopedicBankDTO(
          o.Id,
          o.Name ?? "",
          o.City ?? "",
          o.CreatedAt
        ))
        .FirstOrDefaultAsync();

      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          OrthopedicBank: orthopedicBank,
          CreatedAt: user.CreatedAt
        ),
        Message: "User updated successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapDelete("/user/{id}",
    [SwaggerOperation(
        Summary = "Delete User",
        Description = "Deletes a user by their ID."
    ),]
    [SwaggerResponse(200, "User deleted successfully", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponse(404, "User not found", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponse(400, "Error deleting user", typeof(ResponseControllerUserDTO)),]
    [SwaggerResponseExample(200, typeof(ExampleResponseDeleteUserDTO)),
    SwaggerResponseExample(404, typeof(ExampleResponseUserNotFoundDTO)),
    SwaggerResponseExample(400, typeof(ExampleResponseErrorUserDTO))]
    async (UserManager<User> userManager, string id) => {
      var user = await userManager.FindByIdAsync(id);
      if (user == null) {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }

      var result = await userManager.DeleteAsync(user);
      if (!result.Succeeded) {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "Error deleting user: " + string.Join(", ", result.Errors.Select(e => e.Description))
        ));
      }

      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: null,
        Message: "User deleted successfully"
      ));
    }).RequireAuthorization();
  }
}
