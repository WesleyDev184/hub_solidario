using System.Net; // Use System.Net for HttpStatusCode
using api.DB;
using api.Modules.Applicants.Dto;
using api.Modules.Applicants.Entity;
using api.Modules.Dependents.Dto; // Needed for ResponseEntityDependentDTO mapping
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace api.Modules.Applicants
{
  public static class ApplicantService
  {
    /// <summary>
    /// Creates a new applicant in the system.
    /// </summary>
    public static async Task<ResponseApplicantsDTO> CreateApplicant(
      RequestCreateApplicantDto request,
      ApiDbContext context,
      CancellationToken ct)
    {
      // Early exit for null request
      if (request == null)
      {
        return new ResponseApplicantsDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
      }

      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        if (string.IsNullOrWhiteSpace(request.Name))
        {
          await transaction.RollbackAsync(ct);
          return new ResponseApplicantsDTO(HttpStatusCode.BadRequest, null, "Name is required.");
        }

        // Check if an applicant with the same CPF or Email already exists
        bool existingApplicant = await context.Applicants.AsNoTracking()
          .AnyAsync(a => a.CPF == request.CPF || a.Email == request.Email, ct);

        if (existingApplicant)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseApplicantsDTO(HttpStatusCode.Conflict, null,
            $"Applicant with CPF '{request.CPF}' or Email '{request.Email}' already exists.");
        }

        Applicant newApplicant = new(
          request.Name,
          request.CPF,
          request.Email,
          request.PhoneNumber,
          request.Address,
          request.IsBeneficiary
        );

        context.Applicants.Add(newApplicant);
        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        // Return the created applicant's data in the response
        ResponseEntityApplicantsDTO responseEntityApplicant = MapToResponseEntityApplicantsDto(newApplicant);
        return new ResponseApplicantsDTO(HttpStatusCode.Created, responseEntityApplicant,
          "Applicant created successfully.");
      }
      catch (Exception ex)
      {
        await transaction.RollbackAsync(ct);
        // Log the exception for debugging purposes
        Console.WriteLine($"Error creating applicant: {ex.Message} - {ex.InnerException?.Message}");
        return new ResponseApplicantsDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while creating the applicant.");
      }
    }

    /// <summary>
    /// Retrieves a single applicant by their ID, including their associated dependents.
    /// </summary>
    public static async Task<ResponseApplicantsDTO> GetApplicant(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
    {
      // Retrieve the applicant entity with related dependents (eager loading)
      Applicant? applicantEntity = await context.Applicants.AsNoTracking()
        .Include(a => a.Dependents) // Include dependents for full details
        .SingleOrDefaultAsync(a => a.Id == id, ct);

      if (applicantEntity == null)
      {
        return new ResponseApplicantsDTO(HttpStatusCode.NotFound, null, $"Applicant with ID '{id}' not found.");
      }

      // Map the entity to the DTO
      ResponseEntityApplicantsDTO applicantDto = MapToResponseEntityApplicantsDto(applicantEntity);

      return new ResponseApplicantsDTO(
        HttpStatusCode.OK,
        applicantDto,
        "Applicant retrieved successfully.");
    }

    /// <summary>
    /// Retrieves a list of all applicants.
    /// </summary>
    public static async Task<ResponseApplicantsListDTO> GetApplicants(
      ApiDbContext context,
      CancellationToken ct)
    {
      // Select directly into the DTO for efficiency, without dependents for list view
      List<ResponseEntityApplicantsDTO> applicants = await context.Applicants.AsNoTracking()
        .Select(a => new ResponseEntityApplicantsDTO(
          a.Id,
          a.Name,
          a.CPF,
          a.Email,
          a.PhoneNumber,
          a.Address,
          a.IsBeneficiary,
          a.BeneficiaryQtd,
          a.CreatedAt,
          null // Dependents are typically not included in list views for performance
        )).ToListAsync(ct);

      return new ResponseApplicantsListDTO(HttpStatusCode.OK, applicants.Count, applicants,
        "Applicants retrieved successfully.");
    }

    /// <summary>
    /// Updates an existing applicant's information.
    /// </summary>
    public static async Task<ResponseApplicantsDTO> UpdateApplicant(
      Guid id,
      RequestUpdateApplicantDto? request,
      ApiDbContext context,
      CancellationToken ct)
    {
      // Early exit for null request
      if (request == null)
      {
        return new ResponseApplicantsDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
      }

      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        Applicant? applicant = await context.Applicants.SingleOrDefaultAsync(a => a.Id == id, ct);

        if (applicant == null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseApplicantsDTO(HttpStatusCode.NotFound, null, $"Applicant with ID '{id}' not found.");
        }

        // Only update if the request property is not null/empty AND different from current value
        if (!string.IsNullOrWhiteSpace(request.Name))
        {
          applicant.SetName(request.Name);
        }

        if (!string.IsNullOrWhiteSpace(request.CPF) && request.CPF != applicant.CPF)
        {
          // Check if another applicant already exists with this CPF
          bool exists = await context.Applicants.AsNoTracking()
            .AnyAsync(a => a.CPF == request.CPF && a.Id != id, ct);

          if (exists)
          {
            await transaction.RollbackAsync(ct);
            return new ResponseApplicantsDTO(HttpStatusCode.Conflict, null,
              $"Applicant with CPF '{request.CPF}' already exists.");
          }

          applicant.SetCPF(request.CPF);
        }

        if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != applicant.Email)
        {
          // Check if another applicant already exists with this Email
          bool exists = await context.Applicants.AsNoTracking()
            .AnyAsync(a => a.Email == request.Email && a.Id != id, ct);

          if (exists)
          {
            await transaction.RollbackAsync(ct);
            return new ResponseApplicantsDTO(HttpStatusCode.Conflict, null,
              $"Applicant with Email '{request.Email}' already exists.");
          }

          applicant.SetEmail(request.Email);
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
        {
          applicant.SetPhoneNumber(request.PhoneNumber);
        }

        if (!string.IsNullOrWhiteSpace(request.Address))
        {
          applicant.SetAddress(request.Address);
        }

        if (request.IsBeneficiary.HasValue)
        {
          applicant.SetIsBeneficiary(request.IsBeneficiary.Value);
        }

        applicant.UpdateTimestamps(); // Assuming this updates the ModifiedAt timestamp

        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        // Return the updated applicant's data in the response
        ResponseEntityApplicantsDTO updatedApplicantDto = MapToResponseEntityApplicantsDto(applicant);
        return new ResponseApplicantsDTO(HttpStatusCode.OK, updatedApplicantDto, "Applicant updated successfully.");
      }
      catch (Exception ex)
      {
        await transaction.RollbackAsync(ct);
        Console.WriteLine($"Error updating applicant: {ex.Message} - {ex.InnerException?.Message}");
        return new ResponseApplicantsDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while updating the applicant.");
      }
    }

    /// <summary>
    /// Deletes an applicant from the database.
    /// Note: This operation does NOT automatically delete associated dependents.
    /// Consider implementing cascade deletion or a business rule to handle dependents.
    /// </summary>
    public static async Task<ResponseApplicantsDTO> DeleteApplicant(
      Guid id,
      ApiDbContext context,
      CancellationToken ct)
    {
      await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
      try
      {
        Applicant? applicant = await context.Applicants
          .Include(a => a.Dependents) // Load dependents to check for them
          .SingleOrDefaultAsync(a => a.Id == id, ct);

        if (applicant == null)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseApplicantsDTO(HttpStatusCode.NotFound, null, $"Applicant with ID '{id}' not found.");
        }

        var dependentCount = applicant.Dependents?.Count ?? 0;

        if (dependentCount > 0)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseApplicantsDTO(HttpStatusCode.Conflict, null,
            $"Cannot delete applicant with ID '{id}' because they have {dependentCount} dependent(s). " +
            "Please delete the dependents first.");
        }

        var applicantId = applicant.Id;

        context.Applicants.Remove(applicant);
        await context.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        // 204 No Content is standard for successful DELETE operations where no content is returned
        return new ResponseApplicantsDTO(HttpStatusCode.OK, null, "Applicant deleted successfully.");
      }
      catch (Exception ex)
      {
        await transaction.RollbackAsync(ct);
        Console.WriteLine($"Error deleting applicant: {ex.Message} - {ex.InnerException?.Message}");
        return new ResponseApplicantsDTO(HttpStatusCode.InternalServerError, null,
          "An unexpected error occurred while deleting the applicant.");
      }
    }

    /// <summary>
    /// Maps an Applicant entity to a ResponseEntityApplicantsDTO, including mapped dependents if available.
    /// </summary>
    private static ResponseEntityApplicantsDTO MapToResponseEntityApplicantsDto(Applicant applicant)
    {
      // Map dependents if they are loaded and exist
      ResponseEntityDependentDTO[]? dependentsDto = applicant.Dependents?
        .Select(d => new ResponseEntityDependentDTO(
          d.Id,
          d.Name,
          d.CPF,
          d.Email,
          d.PhoneNumber,
          d.Address,
          d.ApplicantId,
          d.CreatedAt
        )).ToArray();

      return new ResponseEntityApplicantsDTO(
        applicant.Id,
        applicant.Name,
        applicant.CPF,
        applicant.Email,
        applicant.PhoneNumber,
        applicant.Address,
        applicant.IsBeneficiary,
        applicant.BeneficiaryQtd,
        applicant.CreatedAt,
        dependentsDto
      );
    }
  }
}