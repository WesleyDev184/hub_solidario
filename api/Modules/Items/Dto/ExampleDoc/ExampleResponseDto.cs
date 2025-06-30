using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Items.Dto.ExampleDoc
{
  // Example for Create Item response (HTTP 201)
  public class ExampleResponseCreateItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: true,
        Data: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            ImageUrl: "https://example.com/item-image.png",
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Item created successfully"
      );
    }
  }

  // Example for Update Item response (HTTP 200)
  public class ExampleResponseUpdateItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: true,
        Data: new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            ImageUrl: "https://example.com/item-image.png",
            Status: "Available",
            StockId: Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          ),
        Message: "Item updated successfully"
      );
    }
  }

  // Example for Not Found Item response (HTTP 404)
  public class ExampleResponseItemNotFoundDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: false,
        Data: null,
        Message: "Item not found"
      );
    }
  }

  public class ExampleResponseItemStockNotFoundDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: false,
        Data: null,
        Message: "Stock not found"
      );
    }
  }

  // Example for Bad Request response (HTTP 400)
  public class ExampleResponseBadRequestItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: false,
        Data: null,
        Message: "Invalid request data"
      );
    }
  }

  // Example for Get All Items response (HTTP 200)
  public class ExampleResponseGetAllItemDTO : IExamplesProvider<ResponseControllerItemListDTO>
  {
    public ResponseControllerItemListDTO GetExamples()
    {
      return new ResponseControllerItemListDTO(
        Success: true,
        Count: 1,
        Data:
        [
          new ResponseEntityItemDTO(
            Id: Guid.NewGuid(),
            SeriaCode: 12345,
            ImageUrl: "https://example.com/item-image.png",
            Status: "Available",
            StockId:Guid.NewGuid(),
            CreatedAt: DateTime.UtcNow
          )
        ],
        Message: "Items retrieved successfully"
      );
    }
  }

  // Example for Get Single Item response (HTTP 200)
  public class ExampleResponseGetItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: true,
        Data: new ResponseEntityItemDTO(
          Id: Guid.NewGuid(),
          SeriaCode: 12345,
          ImageUrl: "https://example.com/item-image.png",
          Status: "Available",
          StockId: Guid.NewGuid(),
          CreatedAt: DateTime.UtcNow
        ),
        Message: "Item retrieved successfully"
      );
    }
  }

  // exemple for conflict response (HTTP 409)
  public class ExampleResponseConflictItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: false,
        Data: null,
        Message: "Conflict: Item already exists"
      );
    }
  }

  // example for delete item response (HTTP 200)
  public class ExampleResponseDeleteItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: true,
        Data: null,
        Message: "Item deleted successfully"
      );
    }
  }

  // internal server error response (HTTP 500)
  public class ExampleResponseInternalServerErrorItemDTO : IExamplesProvider<ResponseControllerItemDTO>
  {
    public ResponseControllerItemDTO GetExamples()
    {
      return new ResponseControllerItemDTO(
        Success: false,
        Data: null,
        Message: "An unexpected error occurred"
      );
    }
  }
}