using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Stocks.Dto.ExampleDoc
{
  public class ExampleRequestCreateStockDto : IExamplesProvider<RequestCreateStockDto>
  {
    public RequestCreateStockDto GetExamples()
    {
      return new RequestCreateStockDto(
        Title: "New Stock Title",
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
        MaintenanceQtd: 5,
        AvailableQtd: 10,
        BorrowedQtd: 2
      );
    }
  }
}