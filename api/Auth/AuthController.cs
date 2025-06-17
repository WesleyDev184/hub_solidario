using api.Auth.Dto;
using api.Auth.Entity;
using Microsoft.AspNetCore.Authentication.BearerToken;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace api.Auth;

public static class AuthController
{

  public static void AuthRoutes(this WebApplication app)
  {
    var authRoutes = app.MapGroup("").WithTags("Auth");

    authRoutes.MapPost("/login", async Task<Results<Ok<AccessTokenResponse>, EmptyHttpResult, ProblemHttpResult>> (HttpRequest request, SignInManager<User> signInManager, RequestLoginUserDto login) =>
    {
      var useCookies = request.Query.ContainsKey("useCookies") && bool.TryParse(request.Query["useCookies"], out var useCookieValue) && useCookieValue;
      var useSessionCookies = request.Query.ContainsKey("useSessionCookies") && bool.TryParse(request.Query["useSessionCookies"], out var useSessionCookieValue) && useSessionCookieValue;

      var useCookieScheme = (useCookies == true) || (useSessionCookies == true);
      var isPersistent = (useCookies == true) && (useSessionCookies != true);
      signInManager.AuthenticationScheme = useCookieScheme ? IdentityConstants.ApplicationScheme : IdentityConstants.BearerScheme;

      var result = await signInManager.PasswordSignInAsync(login.Email, login.Password, isPersistent, lockoutOnFailure: true);

      if (!result.Succeeded)
      {
        return TypedResults.Problem(result.ToString(), statusCode: StatusCodes.Status401Unauthorized);
      }

      // The signInManager already produced the needed response in the form of a cookie or bearer token.
      return TypedResults.Empty;
    });

    authRoutes.MapPost("/logout", async (SignInManager<User> signInManager) =>
    {
      await signInManager.SignOutAsync();
      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: null,
        Message: "User logged out successfully"
      ));
    });

    authRoutes.MapPost("/user", async (UserManager<User> userManager, RequestCreateUserDto newUser) =>
    {
      if (string.IsNullOrWhiteSpace(newUser.Email) || string.IsNullOrWhiteSpace(newUser.Password))
      {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "Email and Password are required"
        ));
      }

      if (await userManager.FindByEmailAsync(newUser.Email) != null)
      {
        return Results.BadRequest(new ResponseControllerUserDTO(
          Success: false,
          Data: null,
          Message: "User with this email already exists"
        ));
      }

      var user = new User
      {
        UserName = newUser.Email,
        Email = newUser.Email,
        Name = newUser.Name,
        PhoneNumber = newUser.PhoneNumber
      };

      var result = await userManager.CreateAsync(user, newUser.Password);

      if (!result.Succeeded)
      {
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

    authRoutes.MapGet("/user", async (UserManager<User> userManager, HttpContext context) =>
    {
      var user = await userManager.GetUserAsync(context.User);
      if (user == null)
      {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }
      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          CreatedAt: user.CreatedAt
        ),
        Message: "User retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapGet("/users", async (UserManager<User> userManager) =>
    {
      var users = await userManager.Users.ToListAsync();
      return Results.Ok(new ResponseControllerUserListDTO(
        Success: true,
        Count: users.Count,
        Data: [.. users.Select(u => new ResponseEntityUserDTO(
          Id: u.Id,
          Name: u.Name ?? "",
          Email: u.Email ?? "",
          PhoneNumber: u.PhoneNumber ?? "",
          CreatedAt: u.CreatedAt
        ))],
        Message: "Users retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapGet("/user/{id}", async (UserManager<User> userManager, string id) =>
    {
      var user = await userManager.FindByIdAsync(id);
      if (user == null)
      {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }
      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          CreatedAt: user.CreatedAt
        ),
        Message: "User retrieved successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapPatch("/user", async (UserManager<User> userManager, HttpContext context, RequestUpdateUserDto updatedUser) =>
    {
      var user = await userManager.GetUserAsync(context.User);
      if (user == null)
      {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }

      user.Name = updatedUser.Name ?? user.Name;
      user.PhoneNumber = updatedUser.PhoneNumber ?? user.PhoneNumber;

      // validate email already exists
      if (updatedUser.Email != null && updatedUser.Email != user.Email)
      {
        var existingUser = await userManager.FindByEmailAsync(updatedUser.Email);
        if (existingUser != null)
        {
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

      if (!result.Succeeded)
      {
        return Results.BadRequest(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found" + string.Join(", ", result.Errors.Select(e => e.Description)
      )));
      }
      return Results.Ok(new ResponseControllerUserDTO(
        Success: true,
        Data: new ResponseEntityUserDTO(
          Id: user.Id,
          Name: user.Name ?? "",
          Email: user.Email ?? "",
          PhoneNumber: user.PhoneNumber ?? "",
          CreatedAt: user.CreatedAt
        ),
        Message: "User updated successfully"
      ));
    }).RequireAuthorization();

    authRoutes.MapDelete("/user/{id}", async (UserManager<User> userManager, string id) =>
    {
      var user = await userManager.FindByIdAsync(id);
      if (user == null)
      {
        return Results.NotFound(new ResponseControllerUserDTO(
        Success: false,
        Data: null,
        Message: "User not found"
      ));
      }

      var result = await userManager.DeleteAsync(user);
      if (!result.Succeeded)
      {
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
