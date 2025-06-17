using api.Modules.Items.Entity;
using api.Modules.OrthopedicBanks.Entity;
using api.Modules.Stocks.Entity;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;

namespace api.DB;

public class ApiDbContext : DbContext
{

  public DbSet<OrthopedicBank> OrthopedicBanks { get; set; }
  public DbSet<Stock> Stocks { get; set; }
  public DbSet<Item> Items { get; set; }

  override protected void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
  {
    if (!optionsBuilder.IsConfigured)
    {
      Env.Load();
      var connectionString = Env.GetString("DB_URL");
      optionsBuilder.UseNpgsql(connectionString);

      optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
    }
  }

}
