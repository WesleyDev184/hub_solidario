using api.Modules.OrthopedicBanks.Entity;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;

namespace api.DB;

public class ApiDbContext : DbContext
{

  public DbSet<OrthopedicBank> OrthopedicBanks { get; set; }

  override protected void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
  {
    if (!optionsBuilder.IsConfigured)
    {
      Env.Load();
      var connectionString = Env.GetString("DB_URL");
      optionsBuilder.UseNpgsql(connectionString);
    }
  }

}
