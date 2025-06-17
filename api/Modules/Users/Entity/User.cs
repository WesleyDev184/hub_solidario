using System;

namespace api.Modules.Users.Entity;

public class User
{
  public Guid Id { get; init; }
  public string Name { get; private set; }
  public string Email { get; private set; }
  public string Password { get; private set; }
  public string Phone { get; private set; }
  public bool IsActive { get; private set; } = true;
  public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
  public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;

  public User(string name, string email, string password, string phone)
  {
    Id = Guid.NewGuid();
    Name = name;
    Email = email;
    Password = password;
    Phone = phone;
  }

  public void SetName(string name)
  {
    Name = name;
  }

  public void SetEmail(string email)
  {
    Email = email;
  }

  public void SetPassword(string password)
  {
    Password = password;
  }

  public void SetPhone(string phone)
  {
    Phone = phone;
  }

  public void SetActive(bool isActive)
  {
    IsActive = isActive;
  }

  public void UpdateTimestamps()
  {
    UpdatedAt = DateTime.UtcNow;
  }
}
