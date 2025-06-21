using System;
using System.Net;
using System.Collections.Generic;
using Swashbuckle.AspNetCore.Filters;
using api.Modules.Stocks.Dto;
using api.Modules.Items.Dto;
using api.Modules.Items.Enum;

namespace api.Modules.Stocks.Dto.ExampleDoc
{
    // Example for Create Stock response (HTTP 201)
    public class ExampleResponseCreateStockDTO : IExamplesProvider<ResponseControllerStockDTO>
    {
        public ResponseControllerStockDTO GetExamples()
        {
            return new ResponseControllerStockDTO(
                Success: true,
                Data: null,
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
                Data: null,
                Message: "Stock already exists"
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
                    Title: "Existing Stock Title",
                    MaintenanceQtd: 5,
                    AvailableQtd: 10,
                    BorrowedQtd: 2,
                    TotalQtd: 17,
                    Items: [
                        new ResponseEntityItemDTO(
                            Id: Guid.NewGuid(),
                            SeriaCode: 23344556,
                            ImageUrl: "https://example.com/image1.jpg",
                            Status: ItemStatus.AVAILABLE.ToString(),
                            CreatedAt: DateTime.UtcNow
                        ),
                        new ResponseEntityItemDTO(
                            Id: Guid.NewGuid(),
                            SeriaCode: 23344557,
                            ImageUrl: "https://example.com/image1.jpg",
                            Status: ItemStatus.MAINTENANCE.ToString(),
                            CreatedAt: DateTime.UtcNow
                        )
                    ],
                    CreatedAt: DateTime.UtcNow
                ),
                Message: "Stock retrieved successfully"
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

    public class ExampleResponseStocksNotFoundDTO : IExamplesProvider<ResponseControllerStockDTO>
    {
        public ResponseControllerStockDTO GetExamples()
        {
            return new ResponseControllerStockDTO(
                Success: false,
                Data: null,
                Message: "Stocks not found"
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
                        MaintenanceQtd: 5,
                        AvailableQtd: 10,
                        BorrowedQtd: 2,
                        TotalQtd: 17,
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