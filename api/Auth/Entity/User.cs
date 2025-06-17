using System;
using Microsoft.AspNetCore.Identity;

namespace api.Auth.Entity;

public class User : IdentityUser
{
  public string Note { get; set; } = string.Empty;

}
