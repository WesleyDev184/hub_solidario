using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Hubs.Dto.ExampleDoc
{
  public class ExampleRequestCreateHubDto : IExamplesProvider<RequestCreateHubDto>
  {
    public RequestCreateHubDto GetExamples()
    {
      return new RequestCreateHubDto(
        Name: "Rotary Orthopedic Center",
        City: "Cuiabá - MT"
      );
    }
  }

  public class ExampleRequestUpdateHubDto : IExamplesProvider<RequestUpdateHubDto>
  {
    public RequestUpdateHubDto GetExamples()
    {
      return new RequestUpdateHubDto(
        Name: "Updated Orthopedic Center",
        City: "Barra do Garças - MT"
      );
    }
  }
}