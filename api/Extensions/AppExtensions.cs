using api.Middlewares;
using Scalar.AspNetCore;
using api.Modules.Applicants;
using api.Modules.Dependents;
using api.Modules.Documents;
using api.Modules.Items;
using api.Modules.Loans;
using api.Modules.Hubs;
using api.Modules.Stocks;
using Microsoft.EntityFrameworkCore;
using api.DB;
using api.Modules.Auth;

namespace api.Extensions
{
  public static class AppExtensions
  {
    public static async Task AppConfig(this WebApplication app)
    {
      // Aplica migrations automaticamente ao iniciar (se habilitado)
      await app.ApplyMigrationsAsync();

      // Configure the HTTP request pipeline.
      app.AppDocConfig();

      app.UseHttpsRedirection();

      //Habilitando a politica de CORS
      app.UseCors();

      app.UseMiddleware<ApiKeyAuthMiddleware>();

      app.AppEndPointsMap();
    }

    private static async Task ApplyMigrationsAsync(this WebApplication app)
    {
      var shouldRunMigrations = Environment.GetEnvironmentVariable("RUN_MIGRATIONS")?.ToLower() == "true";
      if (!shouldRunMigrations)
      {
        Console.WriteLine("Migrations disabled. Set RUN_MIGRATIONS=true to enable.");
        return;
      }

      int maxRetries = 5;
      int delay = 5000; // 5 seconds

      for (int attempt = 1; attempt <= maxRetries; attempt++)
      {
        try
        {
          using var scope = app.Services.CreateScope();

          Console.WriteLine($"Attempting to apply migrations (attempt {attempt}/{maxRetries})...");

          var apiDb = scope.ServiceProvider.GetRequiredService<ApiDbContext>();
          await apiDb.Database.MigrateAsync();
          Console.WriteLine("API migrations applied successfully!");

          var authDb = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
          await authDb.Database.MigrateAsync();
          Console.WriteLine("Auth migrations applied successfully!");

          Console.WriteLine("All migrations applied successfully!");
          return;
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Error applying migrations (attempt {attempt}/{maxRetries}): {ex.Message}");

          if (attempt == maxRetries)
          {
            Console.WriteLine("Max retry attempts reached. Application will exit.");
            throw;
          }

          Console.WriteLine($"Retrying in {delay / 1000} seconds...");
          await Task.Delay(delay);
        }
      }
    }

    private static void AppDocConfig(this WebApplication app)
    {
      app.UseSwagger(c =>
      {
        c.RouteTemplate = "/openapi/{documentName}.json";
      });
      app.MapScalarApiReference(opt =>
      {
        opt.Title = "Rotary API Reference";
        opt.ShowSidebar = true;
        opt.Theme = ScalarTheme.DeepSpace;
        opt.Favicon =
          "https://clubrunner.blob.core.windows.net/00000002427/PhotoAlbum/branding/Mark-of-Excellence-4992.png";
        opt.HideDarkModeToggle = true;
        opt.HideClientButton = true;
        opt.HideModels = true;
        opt.AddPreferredSecuritySchemes(new[] { "ApiKey" })
          .AddApiKeyAuthentication("ApiKey", apiKey =>
          {
            apiKey.Value = "your_api_key_here";
          });
      });
    }

    private static void AppEndPointsMap(this WebApplication app)
    {
      app.AuthRoutes();
      app.HubRoutes();
      app.StockRoutes();
      app.ItemRoutes();
      app.ApplicantRoutes();
      app.DependentRoutes();
      app.LoanRoutes();
      app.DocumentRoutes();
    }
  }
}