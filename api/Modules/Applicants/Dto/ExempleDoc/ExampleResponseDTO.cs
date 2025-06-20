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
                Data: null,
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
                Data: null,
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
                        Dependents: null
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
                    Dependents: null
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