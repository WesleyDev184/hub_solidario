using System;
using System.Net;
using System.Collections.Generic;
using Swashbuckle.AspNetCore.Filters;
using api.Modules.Loans.Dto;
using api.Modules.Items.Dto;
using api.Modules.Applicants.Dto;
using api.Auth.Dto;

namespace api.Modules.Loans.Dto.ExampleDoc
{
    // Example for Create Loan response (HTTP 201)
    public class ExampleResponseCreateLoanDTO : IExamplesProvider<ResponseControllerLoanDTO>
    {
        public ResponseControllerLoanDTO GetExamples()
        {
            return new ResponseControllerLoanDTO(
                Success: true,
                null,
                Message: "Loan created successfully"
            );
        }
    }

    // Example for Update Loan response (HTTP 200)
    public class ExampleResponseUpdateLoanDTO : IExamplesProvider<ResponseControllerLoanDTO>
    {
        public ResponseControllerLoanDTO GetExamples()
        {
            return new ResponseControllerLoanDTO(
                Success: true,
                Data: null,
                Message: "Loan updated successfully"
            );
        }
    }

    // Example for Loan Not Found response (HTTP 404)
    public class ExampleResponseLoanNotFoundDTO : IExamplesProvider<ResponseControllerLoanDTO>
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

    // Example for Loans Not Found response (HTTP 404)
    public class ExampleResponseLoansNotFoundDTO : IExamplesProvider<ResponseControllerLoanListDTO>
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
    public class ExampleResponseErrorDTO : IExamplesProvider<ResponseControllerLoanDTO>
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
    public class ExampleResponseGetAllLoanDTO : IExamplesProvider<ResponseControllerLoanListDTO>
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
                        ReturnDate: DateTime.UtcNow.AddDays(7),
                        Reason: "Loaning item for temporary use",
                        IsActive: true,
                        Item: 12345,
                        Applicant: "John Doe",
                        Responsible: "Jane Smith",
                        CreatedAt: DateTime.UtcNow
                    )
                ],
                Message: "Loans retrieved successfully"
            );
        }
    }

    // Example for Get Single Loan response (HTTP 200)
    public class ExampleResponseGetLoanDTO : IExamplesProvider<ResponseControllerLoanDTO>
    {
        public ResponseControllerLoanDTO GetExamples()
        {
            return new ResponseControllerLoanDTO(
                Success: true,
                Data: new ResponseEntityLoanDTO(
                    Id: Guid.NewGuid(),
                    ReturnDate: DateTime.UtcNow.AddDays(7),
                    Reason: "Loaning item for temporary use",
                    IsActive: true,
                    Item: new ResponseEntityItemDTO(
                        Id: Guid.NewGuid(),
                        SeriaCode: 12345,
                        ImageUrl: "https://example.com/item-image.png",
                        Status: "Available",
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
                        Dependents: null
                    ),
                    Responsible: new ResponseEntityUserDTO(
                        Id: Guid.NewGuid(),
                        Name: "Jane Smith",
                        Email: "jane.smith@example.com",
                        PhoneNumber: "11888888888",
                        OrthopedicBank: null,
                        CreatedAt: DateTime.UtcNow
                    ),
                    CreatedAt: DateTime.UtcNow
                ),
                Message: "Loan retrieved successfully"
            );
        }
    }

    // example delete loan response (HTTP 200)
    public class ExampleResponseDeleteLoanDTO : IExamplesProvider<ResponseControllerLoanDTO>
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