using api.Modules.Stocks.Dto;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.OrthopedicBanks.Dto.ExampleDoc
{
  // Example for Create OrthopedicBank response (HTTP 201)
  public class ExampleResponseCreateOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
  {
    public ResponseControllerOrthopedicBankDTO GetExamples()
    {
      return new ResponseControllerOrthopedicBankDTO(
        Success: true,
        Data: new ResponseEntityOrthopedicBankDTO(
            Id: Guid.NewGuid(),
            Name: "Central Orthopedic Bank",
            City: "São Paulo",
            null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Orthopedic bank created successfully"
      );
    }
  }

  // Example for Update OrthopedicBank response (HTTP 200)
  public class ExampleResponseUpdateOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
  {
    public ResponseControllerOrthopedicBankDTO GetExamples()
    {
      return new ResponseControllerOrthopedicBankDTO(
        Success: true,
        Data: new ResponseEntityOrthopedicBankDTO(
            Id: Guid.NewGuid(),
            Name: "Central Orthopedic Bank",
            City: "São Paulo",
            null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Orthopedic bank updated successfully"
      );
    }
  }

  // Example for Not Found OrthopedicBank response (HTTP 404)
  public class ExampleResponseOrthopedicBankNotFoundDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
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

  public class ExampleResponseOrthopedicBanksNotFoundDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
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
  public class ExampleResponseBadRequestOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
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

  // Example for Internal Server Error response (HTTP 500)
  public class
    ExampleResponseInternalServerErrorOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
  {
    public ResponseControllerOrthopedicBankDTO GetExamples()
    {
      return new ResponseControllerOrthopedicBankDTO(
        Success: false,
        Data: null,
        Message: "An unexpected error occurred"
      );
    }
  }

  // Response conflict example (HTTP 409)
  public class ExampleResponseConflictOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
  {
    public ResponseControllerOrthopedicBankDTO GetExamples()
    {
      return new ResponseControllerOrthopedicBankDTO(
        Success: false,
        Data: null,
        Message: "An orthopedic bank with this name already exists"
      );
    }
  }

  // Example for Get All OrthopedicBanks response (HTTP 200)
  public class ExampleResponseGetAllOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankListDTO>
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
            null,
            CreatedAt: DateTime.UtcNow
          )
        ],
        Message: "Orthopedic banks retrieved successfully"
      );
    }
  }

  // Example for Get OrthopedicBank by ID response (HTTP 200)
  public class ExampleResponseGetOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
  {
    public ResponseControllerOrthopedicBankDTO GetExamples()
    {
      return new ResponseControllerOrthopedicBankDTO(
        Success: true,
        Data: new ResponseEntityOrthopedicBankDTO(
          Id: Guid.NewGuid(),
          Name: "Central Orthopedic Bank",
          City: "São Paulo",
          [
            new ResponseEntityStockDTO(
              Id: Guid.NewGuid(),
              Title: "Existing Stock Title",
              MaintenanceQtd: 5,
              AvailableQtd: 10,
              BorrowedQtd: 2,
              TotalQtd: 17,
              null,
              null,
              DateTime.UtcNow)
          ],
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Orthopedic bank retrieved successfully"
      );
    }
  }

  // Example for Delete OrthopedicBank response (HTTP 200)
  public class ExampleResponseDeleteOrthopedicBankDto : IExamplesProvider<ResponseControllerOrthopedicBankDTO>
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