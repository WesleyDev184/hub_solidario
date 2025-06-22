using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Applicants.Dto.ExempleDoc;

public class ExampleRequestCreateApplicantDTO : IExamplesProvider<RequestCreateApplicantDto>
{
  public RequestCreateApplicantDto GetExamples()
  {
    return new RequestCreateApplicantDto(
      Name: "John Doe",
      CPF: "12345678901",
      Email: "john.doe@example.com",
      PhoneNumber: "11999999999",
      Address: "123 Main St, City",
      IsBeneficiary: true
    );
  }
}

public class ExampleRequestUpdateApplicantDTO : IExamplesProvider<RequestUpdateApplicantDto>
{
  public RequestUpdateApplicantDto GetExamples()
  {
    return new RequestUpdateApplicantDto(
      Name: "John Doe Updated",
      CPF: "12345678901",
      Email: "john.updated@example.com",
      PhoneNumber: "11888888888",
      Address: "456 Another St, City",
      IsBeneficiary: false
    );
  }
}