using api.Extensions;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);


// Add HealthChecks service
builder.Services.AddHealthChecks();

// Service Configuration Extension.
builder.BuilderConfig();

WebApplication app = builder.Build();

// App Configuration Extension.
await app.AppConfig();

// rota de health check
app.MapHealthChecks("/health");

app.Run();