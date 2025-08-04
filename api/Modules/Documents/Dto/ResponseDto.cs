namespace api.Modules.Documents.Dto;

using System.Net;

//Entity Response
public record ResponseEntityDocumentsDTO(
  Guid Id,
  string OriginalFileName,
  string StorageUrl,
  Guid ApplicantId,
  Guid? DependentId,
  DateTime CreatedAt
);

//Controller Response
public record ResponseControllerDocumentsDTO(
  HttpStatusCode StatusCode,
  ResponseEntityDocumentsDTO? Data,
  string Message
);

//List Response
public record ResponseDocumentsDTO(
  HttpStatusCode StatusCode,
  List<ResponseEntityDocumentsDTO>? Data,
  string Message
);
