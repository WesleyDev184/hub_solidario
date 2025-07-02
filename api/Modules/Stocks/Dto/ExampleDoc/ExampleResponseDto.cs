using Swashbuckle.AspNetCore.Filters;
using api.Modules.Items.Dto;
using api.Modules.Items.Enum;
using api.Modules.OrthopedicBanks.Dto;

namespace api.Modules.Stocks.Dto.ExampleDoc
{
  // Example for Create Stock response (HTTP 201)
  public class ExampleResponseCreateStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: true,
        Data: new ResponseEntityStockDTO(
            Id: Guid.NewGuid(),
            ImageUrl: "https://example.com/image.jpg",
            Title: "Existing Stock Title",
            MaintenanceQtd: 5,
            AvailableQtd: 10,
            BorrowedQtd: 2,
            TotalQtd: 17,
            OrthopedicBankId: Guid.NewGuid(),
            OrthopedicBank: null,
            Items: null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Stock created successfully"
      );
    }
  }

  // Example for Conflict Stock response (HTTP 409)
  public class ExampleResponseConflictStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: false,
        Data: new ResponseEntityStockDTO(
            Id: Guid.NewGuid(),
            ImageUrl: "https://example.com/image.jpg",
            Title: "Existing Stock Title",
            MaintenanceQtd: 5,
            AvailableQtd: 10,
            BorrowedQtd: 2,
            TotalQtd: 17,
            OrthopedicBankId: Guid.NewGuid(),
            OrthopedicBank: null,
            Items: null,
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Stock with name already exists"
      );
    }
  }

  //response bad request
  public class ExampleResponseBadRequestStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: false,
        Data: null,
        Message: "Invalid request data"
      );
    }
  }

  // response for internal server error
  public class ExampleResponseInternalServerErrorStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: false,
        Data: null,
        Message: "An unexpected error occurred"
      );
    }
  }

  // Example for Get Stock response (HTTP 200)
  public class ExampleResponseGetStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: true,
        Data: new ResponseEntityStockDTO(
          Id: Guid.NewGuid(),
          ImageUrl: "https://example.com/image.jpg",
          Title: "Existing Stock Title",
          MaintenanceQtd: 5,
          AvailableQtd: 10,
          BorrowedQtd: 2,
          TotalQtd: 17,
          OrthopedicBankId: Guid.NewGuid(),
          OrthopedicBank: new ResponseEntityOrthopedicBankDTO(
            Id: Guid.NewGuid(),
            Name: "Orthopedic Bank Name",
            City: "Barra do Garças - MT",
            null,
            CreatedAt:
            DateTime.UtcNow
          ),
          Items:
          [
            new ResponseEntityItemDTO(
              Id:
              Guid.NewGuid(),
              SeriaCode:
              23344556,
              Status:
              ItemStatus.AVAILABLE.ToString(),
              StockId:
              Guid.NewGuid(),
              CreatedAt:
              DateTime.UtcNow
            ),
            new ResponseEntityItemDTO(
              Id: Guid.NewGuid(),
              SeriaCode: 23344557,
              Status: ItemStatus.MAINTENANCE.ToString(),
              StockId: Guid.NewGuid(),
              CreatedAt: DateTime.UtcNow
            )
          ],
          CreatedAt:
          DateTime.UtcNow
        ),
        Message:
        "Stock retrieved successfully"
      );
    }
  }

  // Example for Stock Not Found response (HTTP 404)
  public class ExampleResponseStockNotFoundDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: false,
        Data: null,
        Message: "Stock not found"
      );
    }
  }

  public class ExampleResponseStockOrthopedicBankNotFoundDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: false,
        Data: null,
        Message: "Orthopedic Bank with is Id not found"
      );
    }
  }

  // Example for Get All Stocks response (HTTP 200)
  public class ExampleResponseGetAllStocksDTO : IExamplesProvider<ResponseControllerStockListDTO>
  {
    public ResponseControllerStockListDTO GetExamples()
    {
      return new ResponseControllerStockListDTO(
        Success: true,
        Count: 1,
        Data:
        [
          new ResponseEntityStockDTO(
            Id: Guid.NewGuid(),
            Title: "Existing Stock Title",
            ImageUrl: "https://example.com/image.jpg",
            MaintenanceQtd: 5,
            AvailableQtd: 10,
            BorrowedQtd: 2,
            TotalQtd: 17,
            OrthopedicBankId: Guid.NewGuid(),
            OrthopedicBank: null,
            Items: null,
            CreatedAt: DateTime.UtcNow
          )
        ],
        Message: "Stocks retrieved successfully"
      );
    }
  }

  // Example for Update Stock response (HTTP 200)
  public class ExampleResponseUpdateStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: true,
        Data: null,
        Message: "Stock updated successfully"
      );
    }
  }

  // Example for Delete Stock response (HTTP 200)
  public class ExampleResponseDeleteStockDTO : IExamplesProvider<ResponseControllerStockDTO>
  {
    public ResponseControllerStockDTO GetExamples()
    {
      return new ResponseControllerStockDTO(
        Success: true,
        Data: null,
        Message: "Stock deleted successfully"
      );
    }
  }
}