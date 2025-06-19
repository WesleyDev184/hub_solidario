using api.Auth.Entity;
using DotNetEnv;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace api.DB;

public class AuthDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid> {
    override protected void OnConfiguring(DbContextOptionsBuilder optionsBuilder) {
        if (!optionsBuilder.IsConfigured) {
            Env.Load();
            var connectionString = Env.GetString("DB_URL");
            optionsBuilder.UseNpgsql(connectionString);

            optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder) {
        modelBuilder.HasDefaultSchema("auth");

        base.OnModelCreating(modelBuilder);
    }
};
