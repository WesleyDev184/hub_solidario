using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Stocks.Dto.ExampleDoc
{
  public class ExampleRequestCreateStockDto : IExamplesProvider<RequestCreateStockDto>
  {
    public RequestCreateStockDto GetExamples()
    {
      return new RequestCreateStockDto(
        Title: "New Stock Title",
        ImageUrl: "https://example.com/image.jpg",
        OrthopedicBankId: Guid.NewGuid()
      );
    }
  }

  public class ExampleRequestUpdateStockDto : IExamplesProvider<RequestUpdateStockDto>
  {
    public RequestUpdateStockDto GetExamples()
    {
      return new RequestUpdateStockDto(
        Title: "Updated Stock Title",
        ImageUrl: "https://example.com/updated_image.jpg",
        MaintenanceQtd: 5,
        AvailableQtd: 10,
        BorrowedQtd: 2
      );
    }
  }
}