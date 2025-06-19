using Swashbuckle.AspNetCore.Filters;

namespace api.Auth.Dto.ExempleDoc;

public class ExampleRequestUserDTO : IExamplesProvider<RequestCreateUserDto> {
    public RequestCreateUserDto GetExamples() {
        return new RequestCreateUserDto(
            Name: "John Doe",
            Email: "Doe@exemple.com",
            Password: "12345678",
            PhoneNumber: "11999999999",
            OrthopedicBankId: Guid.Parse("00000000-0000-0000-0000-000000000000")
        );
    }
}

public class ExampleRequestUpdateUserDTO : IExamplesProvider<RequestUpdateUserDto> {
    public RequestUpdateUserDto GetExamples() {
        return new RequestUpdateUserDto(
            Name: "John Doe",
            Email: "Doe@exemple.com",
            Password: "12345678",
            PhoneNumber: "11999999999"
        );
    }
}

public class ExampleRequestLoginUserDTO : IExamplesProvider<RequestLoginUserDto> {
    public RequestLoginUserDto GetExamples() {
        return new RequestLoginUserDto(
            Email: "Doe@exemple.com",
            Password: "12345678");
    }
}
