using api.Auth;
using api.Middlewares;
using Scalar.AspNetCore;
using api.Modules.Applicants;
using api.Modules.Dependents;
using api.Modules.Items;
using api.Modules.Loans;
using api.Modules.OrthopedicBanks;
using api.Modules.Stocks;

namespace api.Extensions
{
  public static class AppExtensions
  {
    public static void AppConfig(this WebApplication app)
    {
      // Configure the HTTP request pipeline.
      app.AppDocConfig();

      app.UseHttpsRedirection();

      //Habilitando a politica de CORS
      app.UseCors();

      app.UseMiddleware<ApiKeyAuthMiddleware>();

      app.AppEndPointsMap();
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
      app.OrthopedicBankRoutes();
      app.StockRoutes();
      app.ItemRoutes();
      app.ApplicantRoutes();
      app.DependentRoutes();
      app.LoanRoutes();
    }
  }
}