using System;
using Microsoft.AspNetCore.Identity;

namespace api.Auth.Entity;

public class User : IdentityUser
{
  public string? Name { get; set; }
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

}
