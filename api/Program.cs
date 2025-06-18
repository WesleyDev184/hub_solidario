using api.Auth;
using api.Auth.Entity;
using api.DB;
using api.Modules.Applicants;
using api.Modules.Dependents;
using api.Modules.Items;
using api.Modules.Loans;
using api.Modules.OrthopedicBanks;
using api.Modules.Stocks;

using DotNetEnv;

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
builder.Services.AddScoped<ApiDbContext>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.AuthRoutes();
app.OrthopedicBankRoutes();
app.StockRoutes();
app.ItemRoutes();
app.ApplicantRoutes();
app.DependentRoutes();
app.LoanRoutes();

app.Run();