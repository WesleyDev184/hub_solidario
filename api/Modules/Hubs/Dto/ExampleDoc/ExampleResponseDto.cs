using api.Modules.Stocks.Dto;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Hubs.Dto.ExampleDoc
{
  // Example for Create Hub response (HTTP 201)
  public class ExampleResponseCreateHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: true,
        Data: new ResponseEntityHubDTO(
            Id: Guid.NewGuid(),
            Name: "Central Hub",
            City: "São Paulo",
            null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Hub created successfully"
      );
    }
  }

  // Example for Update Hub response (HTTP 200)
  public class ExampleResponseUpdateHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: true,
        Data: new ResponseEntityHubDTO(
            Id: Guid.NewGuid(),
            Name: "Central Hub",
            City: "São Paulo",
            null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Hub updated successfully"
      );
    }
  }

  // Example for Not Found Hub response (HTTP 404)
  public class ExampleResponseHubNotFoundDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: false,
        Data: null,
        Message: "Hub not found"
      );
    }
  }

  public class ExampleResponseHubsNotFoundDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: false,
        Data: null,
        Message: "Hubs not found"
      );
    }
  }

  // Example for Bad Request response (HTTP 400)
  public class ExampleResponseBadRequestHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: false,
        Data: null,
        Message: "Invalid request data"
      );
    }
  }

  // Example for Internal Server Error response (HTTP 500)
  public class
    ExampleResponseInternalServerErrorHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: false,
        Data: null,
        Message: "An unexpected error occurred"
      );
    }
  }

  // Response conflict example (HTTP 409)
  public class ExampleResponseConflictHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: false,
        Data: null,
        Message: "An Hub with this name already exists"
      );
    }
  }

  // Example for Get All Hubs response (HTTP 200)
  public class ExampleResponseGetAllHubDto : IExamplesProvider<ResponseControllerHubListDTO>
  {
    public ResponseControllerHubListDTO GetExamples()
    {
      return new ResponseControllerHubListDTO(
        Success: true,
        Count: 1,
        Data:
        [
          new ResponseEntityHubDTO(
            Id: Guid.NewGuid(),
            Name: "Central Hub",
            City: "São Paulo",
            null,
            CreatedAt: DateTime.UtcNow
          )
        ],
        Message: "Hubs retrieved successfully"
      );
    }
  }

  // Example for Get Hub by ID response (HTTP 200)
  public class ExampleResponseGetHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: true,
        Data: new ResponseEntityHubDTO(
          Id: Guid.NewGuid(),
          Name: "Central Hub",
          City: "São Paulo",
          [
            new ResponseEntityStockDTO(
              Id: Guid.NewGuid(),
              Title: "Existing Stock Title",
              ImageUrl: "https://example.com/image.jpg",
              MaintenanceQtd: 5,
              AvailableQtd: 10,
              BorrowedQtd: 2,
              TotalQtd: 17,
              HubId: Guid.NewGuid(),
              null,
              null,
              DateTime.UtcNow)
          ],
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Hub retrieved successfully"
      );
    }
  }

  // Example for Delete Hub response (HTTP 200)
  public class ExampleResponseDeleteHubDto : IExamplesProvider<ResponseControllerHubDTO>
  {
    public ResponseControllerHubDTO GetExamples()
    {
      return new ResponseControllerHubDTO(
        Success: true,
        Data: null,
        Message: "Hub deleted successfully"
      );
    }
  }
}