using Swashbuckle.AspNetCore.Annotations;

namespace api.Modules.OrthopedicBanks.Dto;

// Create OrthopedicBank
public record RequestCreateOrthopedicBankDto(
    [SwaggerParameter(Description = "Name of the orthopedic bank", Required = true)]
    string Name,

    [SwaggerParameter(Description = "City of the orthopedic bank", Required = true)]
    string City
);

public record RequestUpdateOrthopedicBankDto(
    [SwaggerParameter(Description = "Updated name of the orthopedic bank", Required = false)]
    string? Name,

    [SwaggerParameter(Description = "Updated city of the orthopedic bank", Required = false)]
    string? City
);