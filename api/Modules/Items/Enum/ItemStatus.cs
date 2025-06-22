using System.ComponentModel;
using System.Text.Json.Serialization;

namespace api.Modules.Items.Enum;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ItemStatus
{
  [Description("The item is under maintenance and cannot be used.")]
  MAINTENANCE,

  [Description("The item is available for use.")]
  AVAILABLE,

  [Description("The item is currently unavailable for use.")]
  UNAVAILABLE,

  [Description("The item has been lost and cannot be recovered.")]
  LOST,

  [Description("The item has been donated and is no longer part of the inventory.")]
  DONATED
}