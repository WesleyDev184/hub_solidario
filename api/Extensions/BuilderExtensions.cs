using api.Auth.Entity;
using api.DB;
using api.Swagger;
using DotNetEnv;
using Microsoft.Extensions.Caching.Hybrid;
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

      builder.AddCaching();
      builder.AddSwagger();
      builder.AddAuthentication();
      builder.AddDatabase();
      builder.AddApplicationServices();
      builder.AddCorsPolicy();
    }

    private static void AddCaching(this WebApplicationBuilder builder)
    {
      var redisConnectionString = Env.GetString("REDIS_URL");
      builder.Services.AddMemoryCache();
      builder.Services.AddStackExchangeRedisCache(options =>
      {
        options.Configuration = redisConnectionString;
      });

      builder.Services.AddHybridCache(options =>
      {
        options.MaximumPayloadBytes = 1024 * 1024;
        options.MaximumKeyLength = 1024;
      });
    }

    private static void AddSwagger(this WebApplicationBuilder builder)
    {
      builder.Services.AddEndpointsApiExplorer();
      builder.Services.AddSwaggerGen(c =>
        {
          c.SwaggerDoc("v1",
            new OpenApiInfo
            {
              Title = "Rotary API",
              Version = "v1.4",
              Description = "API for Rotary Club orthosis loan management system.",
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
    }

    private static void AddAuthentication(this WebApplicationBuilder builder)
    {
      builder.Services.AddAuthentication();
      builder.Services.AddAuthorization();
      builder.Services
        .AddIdentityApiEndpoints<User>()
        .AddEntityFrameworkStores<AuthDbContext>();
    }

    private static void AddDatabase(this WebApplicationBuilder builder)
    {
      builder.Services.AddDbContext<AuthDbContext>();
      builder.Services.AddScoped<ApiDbContext>();
    }

    private static void AddApplicationServices(this WebApplicationBuilder builder)
    {
      // Aqui você pode adicionar services específicos dos módulos quando necessário
      // Exemplo:
      // builder.Services.AddScoped<IApplicantService, ApplicantService>();
      // builder.Services.AddScoped<ILoanService, LoanService>();
    }

    private static void AddCorsPolicy(this WebApplicationBuilder builder)
    {
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