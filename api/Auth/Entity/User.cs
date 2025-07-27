using Microsoft.AspNetCore.Identity;

namespace api.Auth.Entity;

public class User : IdentityUser<Guid>
{
  public string? Name { get; set; }
  public Guid? HubId { get; set; }
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}