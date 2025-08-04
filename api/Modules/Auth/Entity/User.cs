using Microsoft.AspNetCore.Identity;

namespace api.Modules.Auth.Entity;

public class User : IdentityUser<Guid>
{
  public string? Name { get; set; }
  public string? DeviceToken { get; set; }
  public Guid? HubId { get; set; }
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}