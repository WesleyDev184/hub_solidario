namespace api.Modules.Loans.Dto;

using Swashbuckle.AspNetCore.Annotations;

// Create Loan
public record RequestCreateLoanDto(
    [SwaggerParameter(Description = "Identifier for the applicant", Required = true)]
    Guid ApplicantId,

    [SwaggerParameter(Description = "Identifier for the responsible person", Required = true)]
    Guid ResponsibleId,

    [SwaggerParameter(Description = "Identifier of the item being loaned", Required = true)]
    Guid ItemId,

    [SwaggerParameter(Description = "Reason for the loan", Required = true)]
    string Reason
);

public record RequestUpdateLoanDto(
    [SwaggerParameter(Description = "Updated reason for the loan", Required = false)]
    string? Reason,

    [SwaggerParameter(Description = "Indicates whether the loan is active", Required = false)]
    bool? IsActive
);