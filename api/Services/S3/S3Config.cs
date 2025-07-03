
namespace api.Services.S3;

public class S3Config
{
  public string ServiceURL { get; set; } = string.Empty;
  public string BucketName { get; set; } = string.Empty;
  public string AccessKey { get; set; } = string.Empty;
  public string SecretKey { get; set; } = string.Empty;
}
