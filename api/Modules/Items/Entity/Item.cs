using api.Modules.Items.Enum;
using api.Modules.Stocks.Entity;

namespace api.Modules.Items.Entity;

public class Item
{

  public Guid Id { get; set; }
  public int SeriaCode { get; private set; }
  public string ImageUrl { get; private set; } = string.Empty;
  public ItemStatus Status { get; private set; }
  public Guid StockId { get; init; }
  public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  // Propriedade de navegação
  public Stock? Stock { get; init; }


  public Item(int seriaCode, string? imageUrl, ItemStatus status, Guid stockId)
  {
    Id = Guid.NewGuid();
    SeriaCode = seriaCode;
    ImageUrl = imageUrl ?? string.Empty;
    Status = status;
    StockId = stockId;
  }

  public void SetStatus(ItemStatus status)
  {
    Status = status;
  }

  public void SetImageUrl(string imageUrl)
  {
    ImageUrl = imageUrl;
  }

  public void SetSeriaCode(int seriaCode)
  {
    SeriaCode = seriaCode;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}
