using System;
using System.Net;
using System.Collections.Generic;
using Swashbuckle.AspNetCore.Filters;
using api.Modules.OrthopedicBanks.Dto;

namespace api.Modules.OrthopedicBanks.Dto.ExampleDoc
{
    // Example for Create OrthopedicBank response (HTTP 201)
    public class ExampleResponseCreateOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: true,
                Data: new ResponseEntityOrthopedicBankDTO(
                    Id: Guid.NewGuid(),
                    Name: "Rotary Orthopedic Center",
                    City: "Cuiabá - MT",
                    CreatedAt: DateTime.UtcNow
                ),
                Message: "Orthopedic bank created successfully"
            );
        }
    }

    // Example for Update OrthopedicBank response (HTTP 200)
    public class ExampleResponseUpdateOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: true,
                Data: new ResponseEntityOrthopedicBankDTO(
                    Id: Guid.NewGuid(),
                    Name: "Updated Orthopedic Bank",
                    City: "Barra do Garças - MT",
                    CreatedAt: DateTime.UtcNow
                ),
                Message: "Orthopedic bank updated successfully"
            );
        }
    }

    // Example for Not Found OrthopedicBank response (HTTP 404)
    public class ExampleResponseOrthopedicBankNotFoundDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: false,
                Data: null,
                Message: "Orthopedic bank not found"
            );
        }
    }

    public class ExampleResponseOrthopedicBanksNotFoundDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: false,
                Data: null,
                Message: "Orthopedic banks not found"
            );
        }
    }

    // Example for Bad Request response (HTTP 400)
    public class ExampleResponseBadRequestOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: false,
                Data: null,
                Message: "Invalid request data"
            );
        }
    }

    // Example for Get All OrthopedicBanks response (HTTP 200)
    public class ExampleResponseGetAllOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankListDTO>
    {
        public ResponseControllerOrthopedicBankListDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankListDTO(
                Success: true,
                Count: 1,
                Data:
                [
                    new ResponseEntityOrthopedicBankDTO(
                        Id: Guid.NewGuid(),
                        Name: "Central Orthopedic Bank",
                        City: "São Paulo",
                        CreatedAt: DateTime.UtcNow
                    )
                ],
                Message: "Orthopedic banks retrieved successfully"
            );
        }
    }

    // Example for Get OrthopedicBank by ID response (HTTP 200)
    public class ExampleResponseGetOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: true,
                Data: new ResponseEntityOrthopedicBankDTO(
                    Id: Guid.NewGuid(),
                    Name: "Central Orthopedic Bank",
                    City: "São Paulo",
                    CreatedAt: DateTime.UtcNow
                ),
                Message: "Orthopedic bank retrieved successfully"
            );
        }
    }

    // Example for Delete OrthopedicBank response (HTTP 200)
    public class ExampleResponseDeleteOrthopedicBankDTO : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
    {
        public ResponseControllerOrthopedicBankDTO GetExamples()
        {
            return new ResponseControllerOrthopedicBankDTO(
                Success: true,
                Data: null,
                Message: "Orthopedic bank deleted successfully"
            );
        }
    }
}