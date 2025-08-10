using Amazon.Runtime;
using Amazon.S3;
using api.DB;
using api.Modules.Auth.Entity;
using api.Services.S3;
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

      builder.AddCaching();
      builder.AddSwagger();
      builder.AddAuthentication();
      builder.AddDatabase();
      builder.AddApplicationServices();
      builder.AddCorsPolicy();
      builder.ConfigureS3();
    }

    private static void ConfigureS3(this WebApplicationBuilder builder)
    {
      var s3Config = new S3Config
      {
        ServiceURL = Env.GetString("S3_SERVICE_URL"),
        BucketName = Env.GetString("S3_DEFAULT_BUCKET"),
        AccessKey = Env.GetString("S3_ACCESS_KEY"),
        SecretKey = Env.GetString("S3_SECRET_KEY")
      };

      // 3. (Opcional mas recomendado) Valida se todas as variáveis foram carregadas
      if (string.IsNullOrEmpty(s3Config.ServiceURL) ||
          string.IsNullOrEmpty(s3Config.BucketName) ||
          string.IsNullOrEmpty(s3Config.AccessKey) ||
          string.IsNullOrEmpty(s3Config.SecretKey))
      {
        throw new InvalidOperationException("Uma ou mais configurações do S3 não foram encontradas no arquivo .env. Verifique o arquivo e reinicie a aplicação.");
      }

      // Registra a configuração usando IOptions pattern
      builder.Services.Configure<S3Config>(options =>
      {
        options.ServiceURL = s3Config.ServiceURL;
        options.BucketName = s3Config.BucketName;
        options.AccessKey = s3Config.AccessKey;
        options.SecretKey = s3Config.SecretKey;
      });

      var credentials = new BasicAWSCredentials(s3Config.AccessKey, s3Config.SecretKey);
      var config = new AmazonS3Config
      {
        ServiceURL = s3Config.ServiceURL,
        ForcePathStyle = true
      };
      builder.Services.AddSingleton<IAmazonS3>(new AmazonS3Client(credentials, config));

      // 3. Registra nosso serviço genérico
      builder.Services.AddScoped<IFileStorageService, S3FileStorageService>();
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
              Title = "Hub API",
              Version = "v1.1",
              Description = "API for Hub Solidario loan management system.",
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
