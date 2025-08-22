namespace api.DB;

using api.Modules.Auth.Entity;
using DotNetEnv;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

public class AuthDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid>
{
  protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
  {
    if (!optionsBuilder.IsConfigured)
    {
      Env.Load();
      var connectionString = Env.GetString("DB_URL")?.Trim();
      optionsBuilder.UseNpgsql(connectionString);

      optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
    }
  }

  protected override void OnModelCreating(ModelBuilder builder)
  {
    builder.HasDefaultSchema("auth");

    base.OnModelCreating(builder);
  }
};