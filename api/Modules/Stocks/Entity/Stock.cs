using System;
using api.Modules.Items.Entity;
using api.Modules.OrthopedicBanks.Entity;

namespace api.Modules.Stocks.Entity;

public class Stock
{
  public Guid Id { get; init; }
  public string Title { get; private set; }
  public string ImageUrl { get; private set; }
  public int MaintenanceQtd { get; private set; } = 0;
  public int AvailableQtd { get; private set; } = 0;
  public int BorrowedQtd { get; private set; } = 0;
  public int TotalQtd { get; private set; } = 0;
  public Guid OrthopedicBankId { get; private set; }
  public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // Propriedade de navegação
  public ICollection<Item> Items { get; init; } = [];
  public OrthopedicBank OrthopedicBank { get; init; } = null!;

  public Stock(string title, string imageUrl, Guid orthopedicBankId)
  {
    Id = Guid.NewGuid();
    Title = title;
    ImageUrl = imageUrl;
    OrthopedicBankId = orthopedicBankId;
  }

  public void SetTitle(string title)
  {
    Title = title;
  }

  public void SetMaintenanceQtd(int qtd)
  {
    MaintenanceQtd = qtd;
    SetTotalQtd();
  }

  public void SetAvailableQtd(int qtd)
  {
    AvailableQtd = qtd;
    SetTotalQtd();
  }

  public void SetBorrowedQtd(int qtd)
  {
    BorrowedQtd = qtd;
    SetTotalQtd();
  }

  private void SetTotalQtd()
  {
    TotalQtd = MaintenanceQtd + AvailableQtd + BorrowedQtd;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}