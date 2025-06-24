using api.Auth.Entity;
using api.DB;
using api.Swagger;
using DotNetEnv;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Filters;

namespace api.Extensions
{
  public static class BuilderExtensions
  {
    public static void BuilderConfig(this WebApplicationBuilder builder)
    {
      Env.Load();

      // Adicionar a chave de API ao IConfiguration
      builder.Configuration["API_KEY"] = Env.GetString("API_KEY");

      builder.BuilderServices();
    }

    private static void BuilderServices(this WebApplicationBuilder builder)
    {
      builder.Services.AddEndpointsApiExplorer();
      builder.Services.AddSwaggerGen(c =>
        {
          c.SwaggerDoc("v1",
            new OpenApiInfo
            {
              Title = "Rotary APi",
              Version = "v1.2",
              Description = "API for Rotary Club orthosis loan management system",
            });
          c.EnableAnnotations();
          c.ExampleFilters();

          // Adiciona o Schema Filter para enums
          c.SchemaFilter<EnumSchemaFilter>();

          // Adicionar esquema de segurança para chave de API
          c.AddSecurityDefinition("ApiKey",
            new OpenApiSecurityScheme
            {
              Description = "API Key needed to access the endpoints. ApiKey: X-Api-Key",
              In = ParameterLocation.Header,
              Name = "x-api-key",
              Type = SecuritySchemeType.ApiKey,
              Scheme = "ApiKeyScheme"
            });

          // Adicionar requisito de segurança global
          c.AddSecurityRequirement(new OpenApiSecurityRequirement
          {
            {
              new OpenApiSecurityScheme
              {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "ApiKey" },
                Scheme = "ApiKeyScheme",
                Name = "ApiKey",
                In = ParameterLocation.Header
              },
              new List<string>()
            }
          });
        }
      );

      builder.Services.AddSwaggerExamplesFromAssemblyOf<Program>();

      // auth
      builder.Services.AddDbContext<AuthDbContext>();
      builder.Services.AddAuthentication();
      builder.Services.AddAuthorization();
      builder.Services
        .AddIdentityApiEndpoints<User>()
        .AddEntityFrameworkStores<AuthDbContext>();

      // api
      builder.Services.AddScoped<ApiDbContext>();

      //Politica de CORS
      builder.Services.AddCors(options =>
      {
        options.AddDefaultPolicy(policy =>
        {
          policy.AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
        });
      });
    }
  }
}