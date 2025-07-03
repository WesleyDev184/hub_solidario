using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.Extensions.Options;

namespace api.Services.S3;

public class S3FileStorageService : IFileStorageService
{
  private readonly IAmazonS3 _s3Client;
  private readonly S3Config _config;

  public S3FileStorageService(IAmazonS3 s3Client, IOptions<S3Config> config)
  {
    _s3Client = s3Client;
    _config = config.Value;
  }

  public async Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType)
  {
    try
    {
      // Debug: Log da configuração
      Console.WriteLine($"S3 Config - BucketName: {_config.BucketName}, ServiceURL: {_config.ServiceURL}");

      var uniqueFileName = $"{Guid.NewGuid()}{Path.GetExtension(fileName)}";

      var putRequest = new PutObjectRequest
      {
        BucketName = _config.BucketName,
        Key = uniqueFileName,
        InputStream = fileStream,
        ContentType = contentType,
        CannedACL = S3CannedACL.PublicRead // Torna o arquivo publicamente acessível
      };

      await _s3Client.PutObjectAsync(putRequest);

      return GetFileUrl(uniqueFileName);
    }
    catch (AmazonS3Exception e)
    {
      Console.WriteLine($"Erro ao fazer upload para o S3: {e.Message}");
      throw; // Re-lança a exceção para ser tratada em um nível superior
    }
  }

  public async Task DeleteFileAsync(string fileNameInBucket)
  {
    try
    {
      var deleteRequest = new DeleteObjectRequest
      {
        BucketName = _config.BucketName,
        Key = fileNameInBucket
      };

      await _s3Client.DeleteObjectAsync(deleteRequest);
    }
    catch (AmazonS3Exception e)
    {
      Console.WriteLine($"Erro ao deletar objeto do S3: {e.Message}");
      throw;
    }
  }

  public string GetFileUrl(string fileNameInBucket)
  {
    // Para MinIO e buckets S3 com acesso público, a URL pode ser montada manualmente.
    // A ServiceURL no config deve terminar sem a barra '/'
    return $"{_config.ServiceURL}/{_config.BucketName}/{fileNameInBucket}";
  }
}