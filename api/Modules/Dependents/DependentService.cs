using api.DB;
using api.Modules.Dependents.Dto;
using api.Modules.Dependents.Entity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Dependents;

public static class DependentService {
    public static async Task<ResponseDependentDTO> CreateDependent(
           RequestCreateDependentDto request,
           ApiDbContext context,
           CancellationToken ct) {
        var applicantExists = await context.Applicants
            .AsNoTracking()
            .AnyAsync(a => a.Id == request.ApplicantId, ct);

        if (!applicantExists) {
            return new ResponseDependentDTO(
                System.Net.HttpStatusCode.NotFound,
                null,
                "Applicant not found");
        }

        if (string.IsNullOrWhiteSpace(request.Name)) {
            return new ResponseDependentDTO(
                System.Net.HttpStatusCode.BadRequest,
                null,
                "Name is required");
        }

        // Verifica se já existe um Dependent com este CPF
        var existingDependent = await context.Dependents.AsNoTracking()
          .AnyAsync(a => a.CPF == request.CPF || a.Email == request.Email, ct);

        if (existingDependent) {
            return new ResponseDependentDTO(
                  System.Net.HttpStatusCode.Conflict,
                  null,
                  "Dependent with this CPF or Email already exists");
        }

        // Cria um novo Dependent
        var newDependent = new Dependent(
            request.Name,
            request.CPF,
            request.Email,
            request.PhoneNumber,
            request.Address,
            request.ApplicantId
        );

        context.Dependents.Add(newDependent);
        await context.SaveChangesAsync(ct);

        return new ResponseDependentDTO(System.Net.HttpStatusCode.Created, null, "Dependent created successfully");
    }

    public static async Task<ResponseDependentDTO> GetDependent(
        Guid id,
        ApiDbContext context,
        CancellationToken ct) {
        // Retrieve the dependent entity from the database
        var dependentEntity = await context.Dependents.AsNoTracking()
            .SingleOrDefaultAsync(d => d.Id == id, ct);

        if (dependentEntity == null) {
            return new ResponseDependentDTO(
                System.Net.HttpStatusCode.NotFound,
                null,
                "Dependent not found");
        }

        // Map the entity to the DTO in memory
        var dependentDto = new ResponseEntityDependentDTO(
            dependentEntity.Id,
            dependentEntity.Name,
            dependentEntity.CPF,
            dependentEntity.Email,
            dependentEntity.PhoneNumber,
            dependentEntity.Address,
            dependentEntity.ApplicantId,
            dependentEntity.CreatedAt
        );

        return new ResponseDependentDTO(System.Net.HttpStatusCode.OK, dependentDto, "Dependent retrieved successfully");
    }

    public static async Task<ResponseDependentListDTO> GetDependent(
          ApiDbContext context,
          CancellationToken ct) {
        var Dependent = await context.Dependents.AsNoTracking().Select(a => new ResponseEntityDependentDTO(
            a.Id,
            a.Name,
            a.CPF,
            a.Email,
            a.PhoneNumber,
            a.Address,
            a.ApplicantId,
            a.CreatedAt
          )).ToListAsync(ct);

        return new ResponseDependentListDTO(System.Net.HttpStatusCode.OK, Dependent.Count, Dependent, "Dependent retrieved successfully");
    }

    public static async Task<ResponseDependentDTO> UpdateDependent(
          Guid id,
          RequestUpdateDependentDto request,
          ApiDbContext context,
          CancellationToken ct) {
        var Dependent = await context.Dependents.SingleOrDefaultAsync(a => a.Id == id, ct);

        if (Dependent == null) {
            return new ResponseDependentDTO(
                System.Net.HttpStatusCode.NotFound,
                null,
                "Dependent not found");
        }

        if (request.Name != null) {
            Dependent.SetName(request.Name);
        }
        if (request.CPF != null) {
            // Verifica se já existe um Dependent com este CPF
            var exists = await context.Dependents.AsNoTracking()
              .AnyAsync(a => a.CPF == request.CPF && a.Id != id, ct);

            if (exists) {
                return new ResponseDependentDTO(
                    System.Net.HttpStatusCode.Conflict,
                    null,
                    "Dependent with this CPF already exists");
            }
            Dependent.SetCPF(request.CPF);
        }
        if (request.Email != null) {
            // Verifica se já existe um Dependent com este Email
            var exists = await context.Dependents.AsNoTracking()
              .AnyAsync(a => a.Email == request.Email && a.Id != id, ct);

            if (exists) {
                return new ResponseDependentDTO(
                    System.Net.HttpStatusCode.Conflict,
                    null,
                    "Dependent with this Email already exists");
            }
            Dependent.SetEmail(request.Email);
        }
        if (request.PhoneNumber != null) {
            Dependent.SetPhoneNumber(request.PhoneNumber);
        }
        if (request.Address != null) {
            Dependent.SetAddress(request.Address);
        }

        Dependent.UpdateTimestamps();

        await context.SaveChangesAsync(ct);

        return new ResponseDependentDTO(System.Net.HttpStatusCode.OK, null, "Dependent updated successfully");
    }

    public static async Task<ResponseDependentDTO> DeleteDependent(
          Guid id,
          ApiDbContext context,
          CancellationToken ct) {
        var Dependent = await context.Dependents.SingleOrDefaultAsync(a => a.Id == id, ct);

        if (Dependent == null) {
            return new ResponseDependentDTO(
                System.Net.HttpStatusCode.NotFound,
                null,
                "Dependent not found");
        }

        context.Dependents.Remove(Dependent);
        await context.SaveChangesAsync(ct);

        return new ResponseDependentDTO(System.Net.HttpStatusCode.OK, null, "Dependent deleted successfully");
    }
}
