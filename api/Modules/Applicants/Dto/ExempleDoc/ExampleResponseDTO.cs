using api.Modules.Dependents.Dto;
using api.Modules.Hubs.Dto;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Applicants.Dto.ExempleDoc
{
  // Response 201 Create
  public class ExampleResponseCreateApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: true,
        Data: new ResponseEntityApplicantsDTO(
            Id: Guid.Parse("00000000-0000-0000-0000-000000000000"),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St, City",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            ProfileImageUrl: "https://bucket.s3.amazonaws.com/profile.jpg",
            Dependents: null,
            Hub: null
          ),
        Message: "Applicant created successfully"
      );
    }
  }

  // Response 200 Update
  public class ExampleResponseUpdateApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: true,
        Data: new ResponseEntityApplicantsDTO(
          Id: Guid.Parse("00000000-0000-0000-0000-000000000000"),
          Name: "John Doe",
          CPF: "12345678901",
          Email: "john.doe@example.com",
          PhoneNumber: "11999999999",
          Address: "123 Main St, City",
          IsBeneficiary: true,
          BeneficiaryQtd: 1,
          CreatedAt: DateTime.UtcNow,
          ProfileImageUrl: null,
          Dependents:
          [
            new ResponseEntityDependentDTO(
              Id: Guid.Parse("11111111-1111-1111-1111-111111111111"),
              Name: "Jane Doe",
              CPF: "10987654321",
              Email: "ex@example.com",
              PhoneNumber: "11999999998",
              Address: "456 Elm St, City",
              Guid.Parse("00000000-0000-0000-0000-000000000000"),
              ProfileImageUrl: "https://example.com/dependent.jpg",
              CreatedAt: DateTime.Now)
          ],
          Hub: new ResponseEntityHubDTO(
            Id: Guid.Parse("22222222-2222-2222-2222-222222222222"),
            Name: "Main Hub",
            City: "Downtown",
            Stocks: null,
            CreatedAt: DateTime.UtcNow
          )
        ),
        Message: "Applicant updated successfully"
      );
    }
  }

  // Response 404 Not Found
  public class ExampleResponseApplicantNotFoundDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: false,
        Data: null,
        Message: "Applicant not found"
      );
    }
  }

  // Response 409 Conflict
  public class ExampleResponseConflictApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: false,
        Data: null,
        Message: "Conflict Error message"
      );
    }
  }

  // Response 400 Bad Request
  public class ExampleResponseBadRequestApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: false,
        Data: null,
        Message: "Bad Request Error message"
      );
    }
  }

  // Response Internal Server Error
  public class ExampleResponseInternalServerErrorApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: false,
        Data: null,
        Message: "Internal Server Error message"
      );
    }
  }

  // Response 200 GetAll Applicants
  public class ExampleResponseGetAllApplicantDTO : IExamplesProvider<ResponseControllerApplicantsListDTO>
  {
    public ResponseControllerApplicantsListDTO GetExamples()
    {
      return new ResponseControllerApplicantsListDTO(
        Success: true,
        Count: 1,
        Data:
        [
          new ResponseEntityApplicantsDTO(
            Id: Guid.Parse("00000000-0000-0000-0000-000000000000"),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St, City",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            ProfileImageUrl: null,
            Dependents: null,
            Hub:null
          )
        ],
        Message: "Applicants retrieved successfully"
      );
    }
  }

  // Response 200 Get Applicant
  public class ExampleResponseGetApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: true,
        Data: new ResponseEntityApplicantsDTO(
          Id: Guid.Parse("00000000-0000-0000-0000-000000000000"),
          Name: "John Doe",
          CPF: "12345678901",
          Email: "john.doe@example.com",
          PhoneNumber: "11999999999",
          Address: "123 Main St, City",
          IsBeneficiary: true,
          BeneficiaryQtd: 1,
          CreatedAt: DateTime.UtcNow,
          ProfileImageUrl: null,
          Dependents:
          [
            new ResponseEntityDependentDTO(
              Id: Guid.Parse("11111111-1111-1111-1111-111111111111"),
              Name: "Jane Doe",
              CPF: "10987654321",
              Email: "ex@example.com",
              PhoneNumber: "11999999998",
              Address: "456 Elm St, City",
              Guid.Parse("00000000-0000-0000-0000-000000000000"),
              ProfileImageUrl: "https://example.com/dependent.jpg",
              CreatedAt: DateTime.Now)
          ],
           Hub: new ResponseEntityHubDTO(
            Id: Guid.Parse("22222222-2222-2222-2222-222222222222"),
            Name: "Main Hub",
            City: "Downtown",
            Stocks: null,
            CreatedAt: DateTime.UtcNow
          )
        ),
        Message: "Applicant retrieved successfully"
      );
    }
  }

  // Response 200 Delete
  public class ExampleResponseDeleteApplicantDTO : IExamplesProvider<ResponseControllerApplicantsDTO>
  {
    public ResponseControllerApplicantsDTO GetExamples()
    {
      return new ResponseControllerApplicantsDTO(
        Success: true,
        Data: null,
        Message: "Applicant deleted successfully"
      );
    }
  }
}