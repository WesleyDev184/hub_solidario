using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Loans.Dto.ExampleDoc
{
  public class ExampleRequestCreateLoanDto : IExamplesProvider<RequestCreateLoanDto>
  {
    public RequestCreateLoanDto GetExamples()
    {
      return new RequestCreateLoanDto(
        ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111"),
        ResponsibleId: Guid.Parse("22222222-2222-2222-2222-222222222222"),
        ItemId: Guid.Parse("33333333-3333-3333-3333-333333333333"),
        Reason: "Loaning item for temporary use"
      );
    }
  }

  public class ExampleRequestUpdateLoanDto : IExamplesProvider<RequestUpdateLoanDto>
  {
    public RequestUpdateLoanDto GetExamples()
    {
      return new RequestUpdateLoanDto(
        Reason: "Updated loan reason",
        IsActive: true
      );
    }
  }
}