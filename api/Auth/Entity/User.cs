using Microsoft.AspNetCore.Identity;

namespace api.Auth.Entity;

public class User : IdentityUser<Guid>
{
  public string? Name { get; set; }
  public Guid? OrthopedicBankId { get; set; }
  public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
