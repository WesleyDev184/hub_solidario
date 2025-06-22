namespace api.DB;

using api.Modules.Applicants.Entity;
using api.Modules.Dependents.Entity;
using api.Modules.Items.Entity;
using api.Modules.Loans.Entity;
using api.Modules.OrthopedicBanks.Entity;
using api.Modules.Stocks.Entity;
using DotNetEnv;
using Microsoft.EntityFrameworkCore;

public class ApiDbContext : DbContext
{
  public DbSet<OrthopedicBank> OrthopedicBanks { get; set; }
  public DbSet<Stock> Stocks { get; set; }
  public DbSet<Item> Items { get; set; }
  public DbSet<Applicant> Applicants { get; set; }
  public DbSet<Dependent> Dependents { get; set; }
  public DbSet<Loan> Loans { get; set; }

  protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
  {
    if (!optionsBuilder.IsConfigured)
    {
      Env.Load();
      var connectionString = Env.GetString("DB_URL");
      optionsBuilder.UseNpgsql(connectionString);
      optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
    }
  }

  protected override void OnModelCreating(ModelBuilder modelBuilder)
  {
    base.OnModelCreating(modelBuilder);

    modelBuilder.Entity<Stock>()
      .HasMany(s => s.Items)
      .WithOne(i => i.Stock)
      .HasForeignKey(i => i.StockId)
      .OnDelete(DeleteBehavior.Cascade);

    modelBuilder.Entity<Applicant>()
      .HasMany(a => a.Dependents)
      .WithOne(d => d.Applicant)
      .HasForeignKey(d => d.ApplicantId)
      .OnDelete(DeleteBehavior.Cascade);

    modelBuilder.Entity<Loan>()
      .HasOne(l => l.Applicant)
      .WithMany()
      .HasForeignKey(l => l.ApplicantId)
      .OnDelete(DeleteBehavior.Restrict);

    modelBuilder.Entity<Loan>()
      .HasOne(l => l.Item)
      .WithMany()
      .HasForeignKey(l => l.ItemId)
      .OnDelete(DeleteBehavior.Restrict);

    modelBuilder.Entity<Applicant>()
      .HasIndex(a => a.CPF)
      .IsUnique();

    modelBuilder.Entity<Dependent>()
      .HasIndex(a => a.CPF)
      .IsUnique();

    modelBuilder.Entity<Stock>()
      .HasIndex(s => s.Title);
  }
}