using Swashbuckle.AspNetCore.Filters;
using api.Modules.Items.Dto;
using api.Modules.Applicants.Dto;
using api.Modules.Dependents.Dto;
using api.Modules.Auth.Dto;

namespace api.Modules.Loans.Dto.ExampleDoc
{
  // Example for Create Loan response (HTTP 201)
  public class ExampleResponseCreateLoanDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: true,
        Data: new ResponseEntityLoanDTO(
          Id: Guid.NewGuid(),
          ImageUrl: "https://example.com/image.jpg",
          ReturnDate: DateTime.UtcNow.AddDays(7),
          Reason: "Loaning item for temporary use",
          IsActive: true,
          Item: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
          Applicant: new ResponseEntityApplicantsDTO(
            Id: Guid.NewGuid(),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            Dependents: null,
            Hub: null,
            ProfileImageUrl: "https://example.com/profile.jpg"
          ),
          Dependent: new ResponseEntityDependentDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Doe",
            CPF: "98765432100",
            Email: "jane.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "456 Elm St",
            ApplicantId: Guid.NewGuid(),
            ProfileImageUrl: null,
            CreatedAt: DateTime.UtcNow
          ),
          Responsible: new ResponseEntityUserDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Smith",
            Email: "jane.smith@example.com",
            PhoneNumber: "11888888888",
            DeviceToken: "exampleDeviceToken",
            Hub: null,
            CreatedAt: DateTime.UtcNow
          ),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Loan created successfully"
      );
    }
  }

  // Example for Update Loan response (HTTP 200)
  public class ExampleResponseUpdateLoanDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: true,
        Data: new ResponseEntityLoanDTO(
          Id: Guid.NewGuid(),
          ImageUrl: "https://example.com/image.jpg",
          ReturnDate: DateTime.UtcNow.AddDays(7),
          Reason: "Loaning item for temporary use",
          IsActive: true,
          Item: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
          Applicant: new ResponseEntityApplicantsDTO(
            Id: Guid.NewGuid(),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            Dependents: null,
            Hub: null,
            ProfileImageUrl: "https://example.com/profile.jpg"
          ),
          Dependent: new ResponseEntityDependentDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Doe",
            CPF: "98765432100",
            Email: "jane.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "456 Elm St",
            ApplicantId: Guid.NewGuid(),
            ProfileImageUrl: null,
            CreatedAt: DateTime.UtcNow
          ),
          Responsible: new ResponseEntityUserDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Smith",
            Email: "jane.smith@example.com",
            PhoneNumber: "11888888888",
             DeviceToken: "exampleDeviceToken",
            Hub: null,
            CreatedAt: DateTime.UtcNow
          ),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Loan updated successfully"
      );
    }
  }

  // Example for Loan Not Found response (HTTP 404)
  public class ExampleResponseLoanNotFoundDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: false,
        Data: null,
        Message: "Loan not found"
      );
    }
  }

  public class ExampleResponseLoanItemOrApplicantNotFoundDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: false,
        Data: null,
        Message: "Item or Applicant not found"
      );
    }
  }

  // ExampleResponseItemNotAvailableDto
  public class ExampleResponseItemNotAvailableDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: false,
        Data: null,
        Message: "Item is not available for loan"
      );
    }
  }

  // Example for Loans Not Found response (HTTP 404)
  public class ExampleResponseLoansNotFoundDto : IExamplesProvider<ResponseControllerLoanListDTO>
  {
    public ResponseControllerLoanListDTO GetExamples()
    {
      return new ResponseControllerLoanListDTO(
        Success: false,
        Count: 0,
        Data: null,
        Message: "No loans found"
      );
    }
  }

  // response for error (HTTP 400)
  public class ExampleResponseErrorDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: false,
        Data: null,
        Message: "An error occurred while processing your request"
      );
    }
  }

  // Example for Get All Loans response (HTTP 200)
  public class ExampleResponseGetAllLoanDto : IExamplesProvider<ResponseControllerLoanListDTO>
  {
    public ResponseControllerLoanListDTO GetExamples()
    {
      return new ResponseControllerLoanListDTO(
        Success: true,
        Count: 1,
        Data:
        [
          new ResponseEntityLoanListDTO(
            Id: Guid.NewGuid(),
            ImageUrl: "https://example.com/image.jpg",
            ReturnDate: DateTime.UtcNow.AddDays(7),
            Reason: "Loaning item for temporary use",
            IsActive: true,
            Item: 12345,
            Applicant: "John Doe",
            Responsible: "Jane Smith",
            Dependent: "Jane Doe",
            CreatedAt: DateTime.UtcNow
          )
        ],
        Message: "Loans retrieved successfully"
      );
    }
  }

  public class ExampleResponseGetLoansFullDataDto : IExamplesProvider<ResponseControllerLoanListFullDataDTO>
  {
    public ResponseControllerLoanListFullDataDTO GetExamples()
    {
      return new ResponseControllerLoanListFullDataDTO(
        Success: true,
        Count: 1,
        Data: [new ResponseEntityLoanDTO(
          Id: Guid.NewGuid(),
          ImageUrl: "https://example.com/image.jpg",
          ReturnDate: DateTime.UtcNow.AddDays(7),
          Reason: "Loaning item for temporary use",
          IsActive: true,
          Item: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
          Applicant: new ResponseEntityApplicantsDTO(
            Id: Guid.NewGuid(),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            Dependents: null,
            Hub: null,
            ProfileImageUrl: "https://example.com/profile.jpg"
          ),
           Dependent: new ResponseEntityDependentDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Doe",
            CPF: "98765432100",
            Email: "jane.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "456 Elm St",
            ApplicantId: Guid.NewGuid(),
            ProfileImageUrl: null,
            CreatedAt: DateTime.UtcNow
          ),
          Responsible: new ResponseEntityUserDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Smith",
            Email: "jane.smith@example.com",
            PhoneNumber: "11888888888",
             DeviceToken: "exampleDeviceToken",
            Hub: null,
            CreatedAt: DateTime.UtcNow
          ),
          CreatedAt: DateTime.UtcNow
        )],
        Message: "Loan retrieved successfully"
      );
    }
  }


  // Example for Get Single Loan response (HTTP 200)
  public class ExampleResponseGetLoanDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: true,
        Data: new ResponseEntityLoanDTO(
          Id: Guid.NewGuid(),
          ImageUrl: "https://example.com/image.jpg",
          ReturnDate: DateTime.UtcNow.AddDays(7),
          Reason: "Loaning item for temporary use",
          IsActive: true,
          Item: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
          Applicant: new ResponseEntityApplicantsDTO(
            Id: Guid.NewGuid(),
            Name: "John Doe",
            CPF: "12345678901",
            Email: "john.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "123 Main St",
            IsBeneficiary: true,
            BeneficiaryQtd: 1,
            CreatedAt: DateTime.UtcNow,
            Dependents: null,
            Hub: null,
            ProfileImageUrl: "https://example.com/profile.jpg"
          ),
           Dependent: new ResponseEntityDependentDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Doe",
            CPF: "98765432100",
            Email: "jane.doe@example.com",
            PhoneNumber: "11999999999",
            Address: "456 Elm St",
            ApplicantId: Guid.NewGuid(),
            ProfileImageUrl: null,
            CreatedAt: DateTime.UtcNow
          ),
          Responsible: new ResponseEntityUserDTO(
            Id: Guid.NewGuid(),
            Name: "Jane Smith",
            Email: "jane.smith@example.com",
            PhoneNumber: "11888888888",
             DeviceToken: "exampleDeviceToken",
            Hub: null,
            CreatedAt: DateTime.UtcNow
          ),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Loan retrieved successfully"
      );
    }
  }

  // example delete loan response (HTTP 200)
  public class ExampleResponseDeleteLoanDto : IExamplesProvider<ResponseControllerLoanDTO>
  {
    public ResponseControllerLoanDTO GetExamples()
    {
      return new ResponseControllerLoanDTO(
        Success: true,
        Data: null,
        Message: "Loan deleted successfully"
      );
    }
  }
}