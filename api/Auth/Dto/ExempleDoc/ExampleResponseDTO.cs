using api.Modules.OrthopedicBanks.Dto;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Filters;

namespace api.Auth.Dto.ExempleDoc;

//Response 201 Create
public class ExampleResponseCreateUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: true,
      Data: null,
      Message: "User created successfully"
    );
  }
}

//Response 200 update
public class ExampleResponseUpdateUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: true,
      Data: null,
      Message: "User updated successfully"
    );
  }
}

//Response 404
public class ExampleResponseUserNotFoundDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: false,
      Data: null,
      Message: "User not found"
    );
  }
}

public class ExampleResponseUserListNotFoundDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: false,
      Data: null,
      Message: "UserS not found"
    );
  }
}

//Response 409 Conflict
public class ExampleResponseConflictUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: false,
      Data: null,
      Message: "Conflict Error message"
    );
  }
}

//Response Error
public class ExampleResponseErrorUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: false,
      Data: null,
      Message: "Error message"
    );
  }
}

//Response 200 GetAll
public class ExampleResponseGetAllUserDTO : IExamplesProvider<ResponseControllerUserListDTO>
{
  public ResponseControllerUserListDTO GetExamples()
  {
    return new ResponseControllerUserListDTO(
      Success: true,
      Count: 1,
      Data:
      [
        new ResponseEntityUserDTO(
          Guid.Parse("00000000-0000-0000-0000-000000000000"),
          "John Doe",
          "Doe@Exemple.com",
          "11999999999",
          null,
          DateTime.UtcNow
        )
      ],
      Message: "Users retrieved successfully"
    );
  }
}

//Response 200 GetUser
public class ExampleResponseGetUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: true,
      Data: new ResponseEntityUserDTO(
        Guid.Parse("00000000-0000-0000-0000-000000000000"),
        "John Doe",
        "Doe@exemple.com",
        "11999999999",
        new ResponseEntityOrthopedicBankDTO(
          Guid.Parse("00000000-0000-0000-0000-000000000000"),
          "Orthopedic Bank Name",
          "Orthopedic Bank Description",
          null,
          DateTime.UtcNow
        ),
        DateTime.UtcNow
      ),
      Message: "User retrieved successfully"
    );
  }
}

//Response 200 Delete
public class ExampleResponseDeleteUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: true,
      Data: null,
      Message: "User deleted successfully"
    );
  }
}

// reponse for logout
public class ExampleResponseLogoutUserDTO : IExamplesProvider<ResponseControllerUserDTO>
{
  public ResponseControllerUserDTO GetExamples()
  {
    return new ResponseControllerUserDTO(
      Success: true,
      Data: null,
      Message: "User logged out successfully"
    );
  }
}

// response for login success
public class ExampleResponseLoginUserDTO : IExamplesProvider<AccessTokenResponseExample>
{
  public AccessTokenResponseExample GetExamples()
  {
    return new AccessTokenResponseExample(
      "Bearer",
      "ThisIsAnExampleAccessToken",
      3600,
      "ThisIsAnExampleRefreshToken");
  }
}

public class AccessTokenResponseExample
{
  public string TokenType { get; set; }
  public string AccessToken { get; set; }
  public int ExpiresIn { get; set; }
  public string RefreshToken { get; set; }

  public AccessTokenResponseExample(string tokenType, string accessToken, int expiresIn, string refreshToken)
  {
    TokenType = tokenType;
    AccessToken = accessToken;
    ExpiresIn = expiresIn;
    RefreshToken = refreshToken;
  }
}

// response for login error
public class ExampleResponseLoginErrorUserDTO : IExamplesProvider<ProblemDetails>
{
  public ProblemDetails GetExamples()
  {
    return new ProblemDetails
    {
      Title = "Login Error",
      Detail = "Invalid email or password.",
      Status = 401,
      Type = "https://example.com/errors/login-error"
    };
  }
}