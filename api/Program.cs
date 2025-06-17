using System.Security.Claims;
using api.Auth;
using api.Auth.Entity;
using api.DB;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

Env.Load();

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// auth
builder.Services.AddDbContext<AuthDbContext>();
builder.Services.AddAuthentication();
builder.Services.AddAuthorization();
builder.Services
    .AddIdentityApiEndpoints<User>()
    .AddEntityFrameworkStores<AuthDbContext>();

// api
// builder.Services.AddScoped<ApiDbContext>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.AuthRoutes();

app.MapGroup("api")
    .WithTags("API")
    .MapGet("/", (ClaimsPrincipal user) => Results.Ok(user.Identity?.Name ?? "Anonymous")).RequireAuthorization();

app.Run();