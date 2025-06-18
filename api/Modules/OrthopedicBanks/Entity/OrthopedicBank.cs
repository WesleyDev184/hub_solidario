using System;

namespace api.Modules.OrthopedicBanks.Entity;

public class OrthopedicBank
{
  public Guid Id { get; init; }
  public string Name { get; private set; }
  public string City { get; private set; }
  public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

  public OrthopedicBank(string name, string city)
  {
    Id = Guid.NewGuid();
    Name = name;
    City = city;
  }

  public void SetName(string name)
  {
    if (string.IsNullOrWhiteSpace(name))
      throw new ArgumentException("Name cannot be empty.", nameof(name));

    Name = name;
  }

  public void SetCity(string city)
  {
    if (string.IsNullOrWhiteSpace(city))
      throw new ArgumentException("City cannot be empty.", nameof(city));

    City = city;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}
