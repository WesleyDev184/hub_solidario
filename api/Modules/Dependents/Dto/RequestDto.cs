namespace api.Modules.Dependents.Dto;

//Create Dependent
public record RequestCreateDependentDto(
    string Name,
    string CPF,
    string Email,
    string PhoneNumber,
    string Address,
    Guid ApplicantId
);

public record RequestUpdateDependentDto(
    string? Name,
    string? CPF,
    string? Email,
    string? PhoneNumber,
    string? Address
);