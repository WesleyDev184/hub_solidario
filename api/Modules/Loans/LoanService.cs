using System.Net;
using api.Auth.Dto;
using api.Auth.Entity;
using api.DB;
using api.Modules.Applicants.Dto;
using api.Modules.Items.Dto;
using api.Modules.Items.Enum;
using api.Modules.Loans.Dto;
using api.Modules.Loans.Entity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Loans;

public static class LoanService
{
    public static async Task<ResponseLoanDTO> CreateLoan(
        RequestCreateLoanDto request,
        ApiDbContext context,
        CancellationToken ct)
    {

        if (request.ApplicantId == Guid.Empty ||
            request.ResponsibleId == Guid.Empty ||
            request.ItemId == Guid.Empty ||
            string.IsNullOrWhiteSpace(request.Reason))
        {
            return new ResponseLoanDTO(
                HttpStatusCode.BadRequest,
                null,
                "All fields are required");
        }

        // Verifica se o item está disponível
        var item = await context.Items.SingleOrDefaultAsync(
            i => i.Id == request.ItemId && i.Status == ItemStatus.AVAILABLE, ct);

        if (item == null)
        {
            return new ResponseLoanDTO(
                HttpStatusCode.Conflict,
                null,
                "Item is not available for loan");
        }

        // Cria um novo empréstimo
        var newLoan = new Loan(
            request.ApplicantId,
            request.ResponsibleId,
            request.ItemId,
            request.Reason);

        context.Loans.Add(newLoan);
        context.SaveChanges();

        return new ResponseLoanDTO(HttpStatusCode.Created, null, "Loan created successfully");
    }

    public static async Task<ResponseLoanDTO> GetLoan(
        Guid id,
        ApiDbContext context,
        UserManager<User> userManager,
        CancellationToken ct)
    {
        var loan = await context.Loans
          .Include(l => l.Item)
          .Include(l => l.Applicant)
          .Where(l => l.Id == id)
          .Select(l => new
          {
              l.Id,
              l.ReturnDate,
              l.Reason,
              l.IsActive,
              l.ResponsibleId,
              Item = l.Item == null ? null : new ResponseEntityItemDTO(
              l.Item.Id,
              l.Item.SeriaCode,
              l.Item.ImageUrl,
              l.Item.Status.ToString(),
              l.Item.CreatedAt
            ),
              Applicant = l.Applicant == null ? null : new ResponseEntityApplicantsDTO(
              l.Applicant.Id,
              l.Applicant.Name,
              l.Applicant.CPF,
              l.Applicant.Email,
              l.Applicant.PhoneNumber,
              l.Applicant.Address,
              l.Applicant.IsBeneficiary,
              l.Applicant.BeneficiaryQtd,
              l.Applicant.CreatedAt,
              null
            ),
              l.CreatedAt
          })
          .SingleOrDefaultAsync(ct);

        if (loan == null)
        {
            return new ResponseLoanDTO(HttpStatusCode.NotFound, null, "Loan not found");
        }

        ResponseEntityUserDTO? responsible = null;
        var user = await userManager.FindByIdAsync(loan.ResponsibleId.ToString());
        if (user != null)
        {
            responsible = new ResponseEntityUserDTO(
              user.Id,
              user.Name ?? string.Empty,
              user.Email ?? string.Empty,
              user.PhoneNumber ?? string.Empty,
              null,
              user.CreatedAt);
        }

        var responseLoan = new ResponseEntityLoanDTO(
          loan.Id,
          loan.ReturnDate,
          loan.Reason,
          loan.IsActive,
          loan.Item,
          loan.Applicant,
          responsible,
          loan.CreatedAt
        );

        if (loan == null)
        {
            return new ResponseLoanDTO(HttpStatusCode.NotFound, null, "Loan not found");
        }

        return new ResponseLoanDTO(HttpStatusCode.OK, responseLoan, "Loan retrieved successfully");
    }

    public static async Task<ResponseLoanListDTO> GetLoans(
        ApiDbContext context,
        UserManager<User> userManager,
        CancellationToken ct)
    {
        var loans = await context.Loans.AsNoTracking()
            .Include(l => l.Applicant)
            .Include(l => l.Item)
            .Where(l => l.IsActive)
            .OrderByDescending(l => l.CreatedAt)
            .Select(l => new
            {
                l.Id,
                l.ResponsibleId,
                l.ReturnDate,
                l.Reason,
                l.IsActive,
                Item = l.Item != null ? l.Item.SeriaCode : 0,
                Applicants = l.Applicant != null ? l.Applicant.Name : string.Empty,
                l.CreatedAt
            }).ToListAsync(ct);

        if (loans.Count == 0)
        {
            return new ResponseLoanListDTO(HttpStatusCode.NotFound, 0, null, "No loans found");
        }

        var responsibleIds = loans.Select(l => l.ResponsibleId).Distinct().ToList();

        var responsibleNames = await userManager.Users
            .Where(u => responsibleIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id, u => u.Name, ct);

        var responseLoans = loans.Select(l => new ResponseEntityLoanListDTO(
            l.Id,
            l.ReturnDate,
            l.Reason,
            l.IsActive,
            l.Item,
            l.Applicants ?? string.Empty,
            responsibleNames.GetValueOrDefault(l.ResponsibleId, string.Empty),
            l.CreatedAt
        )).ToList();

        return new ResponseLoanListDTO(HttpStatusCode.OK, loans.Count, responseLoans, "Loans retrieved successfully");
    }

    public static async Task<ResponseLoanDTO> UpdateLoan(
        Guid id,
        RequestUpdateLoanDto request,
        ApiDbContext context,
        CancellationToken ct)
    {
        var loan = await context.Loans
            .SingleOrDefaultAsync(l => l.Id == id, ct);

        if (loan == null)
        {
            return new ResponseLoanDTO(HttpStatusCode.NotFound, null, "Loan not found");
        }

        if (!string.IsNullOrWhiteSpace(request.Reason))
        {
            loan.Reason = request.Reason;
        }

        if (request.IsActive.HasValue)
        {
            loan.IsActive = request.IsActive.Value;
        }

        loan.UpdateTimestamps();
        await context.SaveChangesAsync(ct);

        return new ResponseLoanDTO(HttpStatusCode.OK, null, "Loan updated successfully");
    }

    public static async Task<ResponseLoanDTO> DeleteLoan(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
    {
        var loan = await context.Loans
            .SingleOrDefaultAsync(l => l.Id == id, ct);

        if (loan == null)
        {
            return new ResponseLoanDTO(HttpStatusCode.NotFound, null, "Loan not found");
        }

        context.Loans.Remove(loan);
        await context.SaveChangesAsync(ct);

        return new ResponseLoanDTO(HttpStatusCode.OK, null, "Loan deleted successfully");
    }
}
