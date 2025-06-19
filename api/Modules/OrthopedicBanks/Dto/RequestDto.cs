namespace api.Modules.OrthopedicBanks.Dto;

//Create OrthopedicBank
public record RequestCreateOrthopedicBankDto(string Name, string City);

public record RequestUpdateOrthopedicBankDto(string? Name, string? City);
