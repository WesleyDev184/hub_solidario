using api.Extensions;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

// Service Configuration Extension.
builder.BuilderConfig();

WebApplication app = builder.Build();

// App Configuration Extension.
await app.AppConfig();

app.Run();