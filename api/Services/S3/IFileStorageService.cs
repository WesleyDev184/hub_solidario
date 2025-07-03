namespace api.Services.S3;

public interface IFileStorageService
{
  /// <summary>
  /// Faz o upload de um arquivo para o bucket e retorna a URL pública.
  /// </summary>
  /// <param name="fileStream">O stream do arquivo a ser enviado.</param>
  /// <param name="fileName">O nome original do arquivo, usado para extrair a extensão.</param>
  /// <param name="contentType">O tipo de conteúdo (MIME type) do arquivo.</param>
  /// <returns>A URL do arquivo no bucket.</returns>
  Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType);

  /// <summary>
  /// Deleta um arquivo do bucket usando seu nome (key).
  /// </summary>
  /// <param name="fileNameInBucket">O nome/key do arquivo como está salvo no bucket.</param>
  Task DeleteFileAsync(string fileNameInBucket);

  /// <summary>
  /// Gera a URL pública para um arquivo já existente no bucket.
  /// </summary>
  /// <param name="fileNameInBucket">O nome/key do arquivo no bucket.</param>
  /// <returns>A URL pública do arquivo.</returns>
  string GetFileUrl(string fileNameInBucket);
}
