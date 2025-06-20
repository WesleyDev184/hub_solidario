using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Dependents.Dto.ExampleDoc
{
    public class ExampleRequestCreateDependentDto : IExamplesProvider<RequestCreateDependentDto>
    {
        public RequestCreateDependentDto GetExamples()
        {
            return new RequestCreateDependentDto(
                Name: "Jane Doe",
                CPF: "10987654321",
                Email: "jane.doe@example.com",
                PhoneNumber: "11888888888",
                Address: "456 Secondary St, City",
                ApplicantId: Guid.Parse("11111111-1111-1111-1111-111111111111")
            );
        }
    }

    public class ExampleRequestUpdateDependentDto : IExamplesProvider<RequestUpdateDependentDto>
    {
        public RequestUpdateDependentDto GetExamples()
        {
            return new RequestUpdateDependentDto(
                Name: "Jane Doe Updated",
                CPF: "10987654321",
                Email: "jane.updated@example.com",
                PhoneNumber: "11777777777",
                Address: "789 Tertiary Ave, City"
            );
        }
    }
}