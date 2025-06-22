using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.OrthopedicBanks.Dto.ExampleDoc
{
  public class ExampleRequestCreateOrthopedicBankDto : IExamplesProvider<RequestCreateOrthopedicBankDto>
  {
    public RequestCreateOrthopedicBankDto GetExamples()
    {
      return new RequestCreateOrthopedicBankDto(
        Name: "Rotary Orthopedic Center",
        City: "Cuiabá - MT"
      );
    }
  }

  public class ExampleRequestUpdateOrthopedicBankDto : IExamplesProvider<RequestUpdateOrthopedicBankDto>
  {
    public RequestUpdateOrthopedicBankDto GetExamples()
    {
      return new RequestUpdateOrthopedicBankDto(
        Name: "Updated Orthopedic Center",
        City: "Barra do Garças - MT"
      );
    }
  }
}