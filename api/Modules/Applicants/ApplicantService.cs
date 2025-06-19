using System.Net;
using api.DB;
using api.Modules.Applicants.Dto;
using api.Modules.Applicants.Entity;
using api.Modules.Dependents.Dto;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Applicants;

public static class ApplicantService {
    public static async Task<ResponseApplicantsDTO> CreateApplicant(
          RequestCreateApplicantDto request,
          ApiDbContext context,
          CancellationToken ct) {
        if (string.IsNullOrWhiteSpace(request.Name)) {
            return new ResponseApplicantsDTO(
                HttpStatusCode.BadRequest,
                null,
                "Name is required");
        }

        // Verifica se já existe um applicant com este CPF
        var existingApplicant = await context.Applicants.AsNoTracking()
          .AnyAsync(a => a.CPF == request.CPF || a.Email == request.Email, ct);

        if (existingApplicant) {
            return new ResponseApplicantsDTO(
                  HttpStatusCode.Conflict,
                  null,
                  "Applicant with this CPF or Email already exists");
        }

        // Cria um novo applicant
        var newApplicant = new Applicant(
            request.Name,
            request.CPF,
            request.Email,
            request.PhoneNumber,
            request.Address,
            request.IsBeneficiary
        );

        context.Applicants.Add(newApplicant);
        await context.SaveChangesAsync(ct);

        return new ResponseApplicantsDTO(HttpStatusCode.Created, null, "Applicant created successfully");
    }

    public static async Task<ResponseApplicantsDTO> GetApplicant(
      Guid id,
      ApiDbContext context,
      CancellationToken ct) {
        // Retrieve the applicant entity with related dependents
        var applicantEntity = await context.Applicants.AsNoTracking()
            .Include(a => a.Dependents)
            .SingleOrDefaultAsync(a => a.Id == id, ct);

        if (applicantEntity == null) {
            return new ResponseApplicantsDTO(
                HttpStatusCode.NotFound,
                null,
                "Applicant not found");
        }

        // Map the entity to the DTO
        var applicantDto = new ResponseEntityApplicantsDTO(
            applicantEntity.Id,
            applicantEntity.Name,
            applicantEntity.CPF,
            applicantEntity.Email,
            applicantEntity.PhoneNumber,
            applicantEntity.Address,
            applicantEntity.IsBeneficiary,
            applicantEntity.BeneficiaryQtd,
            applicantEntity.CreatedAt,
            applicantEntity.Dependents?.Select(d => new ResponseEntityDependentDTO(
                d.Id,
                d.Name,
                d.CPF,
                d.Email,
                d.PhoneNumber,
                d.Address,
                d.ApplicantId,
                d.CreatedAt
            )).ToArray()
        );

        return new ResponseApplicantsDTO(
            HttpStatusCode.OK,
            applicantDto,
            "Applicant retrieved successfully");
    }

    public static async Task<ResponseApplicantsListDTO> GetApplicants(
          ApiDbContext context,
          CancellationToken ct) {
        var applicants = await context.Applicants.AsNoTracking().Select(a => new ResponseEntityApplicantsDTO(
            a.Id,
            a.Name,
            a.CPF,
            a.Email,
            a.PhoneNumber,
            a.Address,
            a.IsBeneficiary,
            a.BeneficiaryQtd,
            a.CreatedAt,
            null
          )).ToListAsync(ct);

        return new ResponseApplicantsListDTO(HttpStatusCode.OK, applicants.Count, applicants, "Applicants retrieved successfully");
    }

    public static async Task<ResponseApplicantsDTO> UpdateApplicant(
          Guid id,
          RequestUpdateApplicantDto request,
          ApiDbContext context,
          CancellationToken ct) {
        var applicant = await context.Applicants.SingleOrDefaultAsync(a => a.Id == id, ct);

        if (applicant == null) {
            return new ResponseApplicantsDTO(
                HttpStatusCode.NotFound,
                null,
                "Applicant not found");
        }

        if (request.Name != null) {
            applicant.SetName(request.Name);
        }
        if (request.CPF != null) {
            // Verifica se já existe um applicant com este CPF
            var exists = await context.Applicants.AsNoTracking()
              .AnyAsync(a => a.CPF == request.CPF && a.Id != id, ct);

            if (exists) {
                return new ResponseApplicantsDTO(
                    HttpStatusCode.Conflict,
                    null,
                    "Applicant with this CPF already exists");
            }
            applicant.SetCPF(request.CPF);
        }
        if (request.Email != null) {
            // Verifica se já existe um applicant com este Email
            var exists = await context.Applicants.AsNoTracking()
              .AnyAsync(a => a.Email == request.Email && a.Id != id, ct);

            if (exists) {
                return new ResponseApplicantsDTO(
                    HttpStatusCode.Conflict,
                    null,
                    "Applicant with this Email already exists");
            }
            applicant.SetEmail(request.Email);
        }
        if (request.PhoneNumber != null) {
            applicant.SetPhoneNumber(request.PhoneNumber);
        }
        if (request.Address != null) {
            applicant.SetAddress(request.Address);
        }
        if (request.IsBeneficiary.HasValue) {
            applicant.SetIsBeneficiary(request.IsBeneficiary.Value);
        }
        applicant.UpdateTimestamps();

        await context.SaveChangesAsync(ct);

        return new ResponseApplicantsDTO(HttpStatusCode.OK, null, "Applicant updated successfully");
    }

    public static async Task<ResponseApplicantsDTO> DeleteApplicant(
          Guid id,
          ApiDbContext context,
          CancellationToken ct) {
        var applicant = await context.Applicants.SingleOrDefaultAsync(a => a.Id == id, ct);

        if (applicant == null) {
            return new ResponseApplicantsDTO(
                HttpStatusCode.NotFound,
                null,
                "Applicant not found");
        }

        context.Applicants.Remove(applicant);
        await context.SaveChangesAsync(ct);

        return new ResponseApplicantsDTO(HttpStatusCode.OK, null, "Applicant deleted successfully");
    }
}
