using api.Auth;
using api.Auth.Entity;
using api.DB;
using api.Middlewares;
using api.Modules.Applicants;
using api.Modules.Dependents;
using api.Modules.Items;
using api.Modules.Loans;
using api.Modules.OrthopedicBanks;
using api.Modules.Stocks;
using api.Swagger;
using DotNetEnv;
using Microsoft.OpenApi.Models;
using Scalar.AspNetCore;
using Swashbuckle.AspNetCore.Filters;

var builder = WebApplication.CreateBuilder(args);

Env.Load();

// Adicionar a chave de API ao IConfiguration
builder.Configuration["API_KEY"] = Env.GetString("API_KEY");

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(
    c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "Rotary APi",
            Version = "v1.0",
            Description = "API for Rotary Club orthosis loan management system",
        });
        c.EnableAnnotations();
        c.ExampleFilters();

        // Adiciona o Schema Filter para enums
        c.SchemaFilter<EnumSchemaFilter>();

        // Adicionar esquema de segurança para chave de API
        c.AddSecurityDefinition("ApiKey", new OpenApiSecurityScheme
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
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "ApiKey"
                },
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

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
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
        opt.Favicon = "https://clubrunner.blob.core.windows.net/00000002427/PhotoAlbum/branding/Mark-of-Excellence-4992.png";
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


app.UseHttpsRedirection();

//Habilitando a politica de CORS
app.UseCors();

app.UseMiddleware<ApiKeyAuthMiddleware>();

app.AuthRoutes();
app.OrthopedicBankRoutes();
app.StockRoutes();
app.ItemRoutes();
app.ApplicantRoutes();
app.DependentRoutes();
app.LoanRoutes();

app.Run();
