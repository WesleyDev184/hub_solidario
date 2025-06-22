using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Dependents.Dto.ExampleDoc
{
  // Response 201 Create
  public class ExampleResponseCreateDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: true,
        Data: new ResponseEntityDependentDTO(
          Id: Guid.NewGuid(),
          Name: "Jane Doe",
          CPF: "10987654321",
          Email: "jane.doe@example.com",
          PhoneNumber: "11888888888",
          Address: "456 Secondary St, City",
          ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111"),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Dependent created successfully"
      );
    }
  }

  // Response 200 Update
  public class ExampleResponseUpdateDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: true,
        Data: new ResponseEntityDependentDTO(
          Id: Guid.NewGuid(),
          Name: "Jane Doe Updated",
          CPF: "10987654321",
          Email: "jane.updated@example.com",
          PhoneNumber: "11777777777",
          Address: "789 Tertiary Ave, City",
          ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111"),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Dependent updated successfully"
      );
    }
  }

  // Response 404 Not Found
  public class ExampleResponseDependentOrApplicantNotFoundDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Dependent or Applicant not found"
      );
    }
  }

  public class ExampleResponseDependentApplicantNotFoundDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Applicant not found"
      );
    }
  }

  public class ExampleResponseDependentNotFoundDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Dependent not found"
      );
    }
  }

  // Response 409 Conflict
  public class ExampleResponseConflictDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Conflict error occurred"
      );
    }
  }

  // Response 400 Bad Request
  public class ExampleResponseBadRequestDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Bad request error occurred"
      );
    }
  }

  // Response Internal Server Error
  public class ExampleResponseInternalServerErrorDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: false,
        Data: null,
        Message: "Internal server error occurred"
      );
    }
  }

  // Response 200 Get All Dependents
  public class ExampleResponseGetAllDependentDTO : IExamplesProvider<ResponseControllerDependentListDTO>
  {
    public ResponseControllerDependentListDTO GetExamples()
    {
      return new ResponseControllerDependentListDTO(
        Success: true,
        Count: 1,
        Data: new List<ResponseEntityDependentDTO>
        {
          new ResponseEntityDependentDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Doe",
            CPF: "10987654321",
            Email: "jane.doe@example.com",
            PhoneNumber: "11888888888",
            Address: "456 Secondary St, City",
            ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111"),
            CreatedAt: DateTime.UtcNow
          )
        },
        Message: "Dependents retrieved successfully"
      );
    }
  }

  // Response 200 Get Single Dependent
  public class ExampleResponseGetDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: true,
        Data: new ResponseEntityDependentDTO(
          Id: Guid.NewGuid(),
          Name: "Jane Doe",
          CPF: "10987654321",
          Email: "jane.doe@example.com",
          PhoneNumber: "11888888888",
          Address: "456 Secondary St, City",
          ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111"),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Dependent retrieved successfully"
      );
    }
  }

  // Response 200 Delete Dependent
  public class ExampleResponseDeleteDependentDTO : IExamplesProvider<ResponseControllerDependentDTO>
  {
    public ResponseControllerDependentDTO GetExamples()
    {
      return new ResponseControllerDependentDTO(
        Success: true,
        Data: null,
        Message: "Dependent deleted successfully"
      );
    }
  }
}