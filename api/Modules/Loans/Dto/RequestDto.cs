namespace api.Modules.Loans.Dto;

//Create Stock
public record RequestCreateLoanDto(
    Guid ApplicantId,
    Guid ResponsibleId,
    Guid ItemId,
    string Reason
    );

public record RequestUpdateLoanDto(
    string? Reason,
    bool? IsActive
    );
