using api.Auth.Entity;
using Microsoft.AspNetCore.Identity;

namespace api.Auth;

public static class AuthController
{

  public static void AuthRoutes(this WebApplication app)
  {
    app.MapIdentityApi<User>().WithTags("Auth");
    var authRoutes = app.MapGroup("").WithTags("Auth");

    authRoutes.MapPost("/Logout", async (SignInManager<User> signInManager) =>
    {
      await signInManager.SignOutAsync();
      return Results.Ok(new { message = "User logged out successfully" });
    });
  }
}
