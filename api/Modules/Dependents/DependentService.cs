using System.Net; // Use System.Net for HttpStatusCode
using api.DB;
using api.Modules.Dependents.Dto;
using api.Modules.Dependents.Entity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Dependents;

public static class DependentService
{
    /// <summary>
    /// Creates a new dependent and associates them with an applicant, incrementing the applicant's beneficiary count.
    /// </summary>
    public static async Task<ResponseDependentDTO> CreateDependent(
        RequestCreateDependentDto request,
        ApiDbContext context,
        CancellationToken ct)
    {
        // Early exit for null request
        if (request == null)
        {
            return new ResponseDependentDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
        }

        // Use a transaction for atomic operations involving multiple entities
        await using var transaction = await context.Database.BeginTransactionAsync(ct);
        try
        {
            var applicant = await context.Applicants
                .SingleOrDefaultAsync(a => a.Id == request.ApplicantId, ct);

            if (applicant == null)
            {
                await transaction.RollbackAsync(ct);
                return new ResponseDependentDTO(HttpStatusCode.NotFound, null, $"Applicant with ID '{request.ApplicantId}' not found.");
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                await transaction.RollbackAsync(ct);
                return new ResponseDependentDTO(HttpStatusCode.BadRequest, null, "Name is required.");
            }

            // Check for existing dependent with the same CPF or Email
            // Using AnyAsync is efficient as it only checks for existence, not retrieves the full entity
            var existingDependent = await context.Dependents.AsNoTracking()
                .AnyAsync(d => d.CPF == request.CPF || d.Email == request.Email, ct);

            if (existingDependent)
            {
                await transaction.RollbackAsync(ct);
                return new ResponseDependentDTO(HttpStatusCode.Conflict, null, "Dependent with this CPF or Email already exists.");
            }

            var newDependent = new Dependent(
                request.Name,
                request.CPF,
                request.Email,
                request.PhoneNumber,
                request.Address,
                request.ApplicantId
            );

            context.Dependents.Add(newDependent);

            // Increment the beneficiary count for the associated applicant
            applicant.SetBeneficiaryQtd(applicant.BeneficiaryQtd + 1);

            await context.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);

            // Return the created dependent's data in the response
            var responseEntityDependent = MapToResponseEntityDependentDTO(newDependent);
            return new ResponseDependentDTO(HttpStatusCode.Created, responseEntityDependent, "Dependent created successfully.");
        }
        catch
        {
            await transaction.RollbackAsync(ct);
            // Log the exception for debugging purposes
            return new ResponseDependentDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while creating the dependent.");
        }
    }

    /// <summary>
    /// Retrieves a single dependent by their ID.
    /// </summary>
    public static async Task<ResponseDependentDTO> GetDependent(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
    {
        var dependentEntity = await context.Dependents.AsNoTracking()
            .SingleOrDefaultAsync(d => d.Id == id, ct);

        if (dependentEntity == null)
        {
            return new ResponseDependentDTO(HttpStatusCode.NotFound, null, $"Dependent with ID '{id}' not found.");
        }

        var dependentDto = MapToResponseEntityDependentDTO(dependentEntity);
        return new ResponseDependentDTO(HttpStatusCode.OK, dependentDto, "Dependent retrieved successfully.");
    }

    /// <summary>
    /// Retrieves a list of all dependents.
    /// </summary>
    public static async Task<ResponseDependentListDTO> GetDependents( // Renamed to GetDependents (plural)
        ApiDbContext context,
        CancellationToken ct)
    {
        var dependents = await context.Dependents.AsNoTracking()
            .Select(d => MapToResponseEntityDependentDTO(d)) // Use helper for mapping
            .ToListAsync(ct);

        return new ResponseDependentListDTO(HttpStatusCode.OK, dependents.Count, dependents, "Dependents retrieved successfully.");
    }

    /// <summary>
    /// Updates an existing dependent's information.
    /// </summary>
    public static async Task<ResponseDependentDTO> UpdateDependent(
        Guid id,
        RequestUpdateDependentDto request,
        ApiDbContext context,
        CancellationToken ct)
    {
        // Early exit for null request
        if (request == null)
        {
            return new ResponseDependentDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
        }

        await using var transaction = await context.Database.BeginTransactionAsync(ct);
        try
        {
            var dependent = await context.Dependents.SingleOrDefaultAsync(d => d.Id == id, ct);

            if (dependent == null)
            {
                await transaction.RollbackAsync(ct);
                return new ResponseDependentDTO(HttpStatusCode.NotFound, null, $"Dependent with ID '{id}' not found.");
            }

            if (request.Name != null)
            {
                dependent.SetName(request.Name);
            }

            if (request.CPF != null && request.CPF != dependent.CPF) // Only check if CPF is provided and changed
            {
                var exists = await context.Dependents.AsNoTracking()
                    .AnyAsync(d => d.CPF == request.CPF && d.Id != id, ct);

                if (exists)
                {
                    await transaction.RollbackAsync(ct);
                    return new ResponseDependentDTO(HttpStatusCode.Conflict, null, $"Dependent with CPF '{request.CPF}' already exists.");
                }
                dependent.SetCPF(request.CPF);
            }

            if (request.Email != null && request.Email != dependent.Email) // Only check if Email is provided and changed
            {
                var exists = await context.Dependents.AsNoTracking()
                    .AnyAsync(d => d.Email == request.Email && d.Id != id, ct);

                if (exists)
                {
                    await transaction.RollbackAsync(ct);
                    return new ResponseDependentDTO(HttpStatusCode.Conflict, null, $"Dependent with Email '{request.Email}' already exists.");
                }
                dependent.SetEmail(request.Email);
            }

            if (request.PhoneNumber != null)
            {
                dependent.SetPhoneNumber(request.PhoneNumber);
            }
            if (request.Address != null)
            {
                dependent.SetAddress(request.Address);
            }

            dependent.UpdateTimestamps(); // Assuming this updates the ModifiedAt timestamp

            await context.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);

            var updatedDependentDto = MapToResponseEntityDependentDTO(dependent);
            return new ResponseDependentDTO(HttpStatusCode.OK, updatedDependentDto, "Dependent updated successfully.");
        }
        catch
        {
            await transaction.RollbackAsync(ct);
            return new ResponseDependentDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while updating the dependent.");
        }
    }

    /// <summary>
    /// Deletes a dependent from the database and decrements the associated applicant's beneficiary count.
    /// </summary>
    public static async Task<ResponseDependentDTO> DeleteDependent(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
    {
        await using var transaction = await context.Database.BeginTransactionAsync(ct);
        try
        {
            var dependent = await context.Dependents.SingleOrDefaultAsync(d => d.Id == id, ct);

            if (dependent == null)
            {
                await transaction.RollbackAsync(ct);
                return new ResponseDependentDTO(HttpStatusCode.NotFound, null, $"Dependent with ID '{id}' not found.");
            }

            context.Dependents.Remove(dependent);

            // Decrement the beneficiary count for the associated applicant
            var applicant = await context.Applicants
                .SingleOrDefaultAsync(a => a.Id == dependent.ApplicantId, ct);

            // Only decrement if the applicant is found to avoid NullReferenceException
            applicant?.SetBeneficiaryQtd(applicant.BeneficiaryQtd - 1);

            await context.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);

            // 204 No Content is standard for successful DELETE operations where no content is returned
            return new ResponseDependentDTO(HttpStatusCode.OK, null, "Dependent deleted successfully.");
        }
        catch
        {
            await transaction.RollbackAsync(ct);
            return new ResponseDependentDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while deleting the dependent.");
        }
    }

    /// <summary>
    /// Maps a Dependent entity to a ResponseEntityDependentDTO.
    /// </summary>
    private static ResponseEntityDependentDTO MapToResponseEntityDependentDTO(Dependent dependent)
    {
        return new ResponseEntityDependentDTO(
            dependent.Id,
            dependent.Name,
            dependent.CPF,
            dependent.Email,
            dependent.PhoneNumber,
            dependent.Address,
            dependent.ApplicantId,
            dependent.CreatedAt
        );
    }
}