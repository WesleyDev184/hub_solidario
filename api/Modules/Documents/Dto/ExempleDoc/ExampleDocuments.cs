namespace api.Modules.Documents.Dto.ExempleDoc;

using System.Net;
using Swashbuckle.AspNetCore.Filters;

//Create Document Examples
public class ExampleRequestCreateDocumentDTO : IExamplesProvider<RequestCreateDocumentDto>
{
  public RequestCreateDocumentDto GetExamples()
  {
    // Note: IFormFile cannot be easily exemplified, this is for documentation purposes
    return new RequestCreateDocumentDto
    {
      DocumentFile = null!, // DocumentFile would be actual file upload
      ApplicantId = Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
      DependentId = Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa7")
    };
  }
}

public class ExampleResponseCreateDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.Created,
      new ResponseEntityDocumentsDTO(
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa8"),
        "document.pdf",
        "https://storage.example.com/documents/3fa85f64-5717-4562-b3fc-2c963f66afa8.pdf",
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa7"),
        DateTime.UtcNow
      ),
      "Document created successfully."
    );
  }
}

//Get Document Examples
public class ExampleResponseGetDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.OK,
      new ResponseEntityDocumentsDTO(
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa8"),
        "document.pdf",
        "https://storage.example.com/documents/3fa85f64-5717-4562-b3fc-2c963f66afa8.pdf",
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
        Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa7"),
        DateTime.UtcNow
      ),
      "Document retrieved successfully."
    );
  }
}

//List Documents Examples
public class ExampleResponseListDocumentsDTO : IExamplesProvider<ResponseDocumentsDTO>
{
  public ResponseDocumentsDTO GetExamples()
  {
    return new ResponseDocumentsDTO(
      HttpStatusCode.OK,
      [
        new ResponseEntityDocumentsDTO(
          Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa8"),
          "document1.pdf",
          "https://storage.example.com/documents/3fa85f64-5717-4562-b3fc-2c963f66afa8.pdf",
          Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
          Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa7"),
          DateTime.UtcNow
        ),
        new ResponseEntityDocumentsDTO(
          Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa9"),
          "document2.pdf",
          "https://storage.example.com/documents/3fa85f64-5717-4562-b3fc-2c963f66afa9.pdf",
          Guid.Parse("3fa85f64-5717-4562-b3fc-2c963f66afa6"),
          null,
          DateTime.UtcNow
        )
      ],
      "Documents retrieved successfully."
    );
  }
}

//Error Examples
public class ExampleResponseConflictDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.Conflict,
      null,
      "Document with this name already exists for this applicant."
    );
  }
}

public class ExampleResponseNotFoundDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.NotFound,
      null,
      "Document not found."
    );
  }
}

public class ExampleResponseBadRequestDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.BadRequest,
      null,
      "Invalid request data provided."
    );
  }
}

public class ExampleResponseInternalServerErrorDocumentDTO : IExamplesProvider<ResponseControllerDocumentsDTO>
{
  public ResponseControllerDocumentsDTO GetExamples()
  {
    return new ResponseControllerDocumentsDTO(
      HttpStatusCode.InternalServerError,
      null,
      "An unexpected error occurred while processing the request."
    );
  }
}
