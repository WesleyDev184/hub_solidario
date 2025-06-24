using api.Extensions;
using Microsoft.EntityFrameworkCore;
using api.DB;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// Service Configuration Extension.
builder.BuilderConfig();

WebApplication app = builder.Build();

// Aplica migrations automaticamente ao iniciar
using (var scope = app.Services.CreateScope())
{
  var apiDb = scope.ServiceProvider.GetRequiredService<ApiDbContext>();
  apiDb.Database.Migrate();

  var authDb = scope.ServiceProvider.GetRequiredService<AuthDbContext>();
  authDb.Database.Migrate();
}

// App Configuration Extension.
app.AppConfig();

app.Run();