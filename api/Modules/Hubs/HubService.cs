using System.Net;
using api.DB;
using api.Modules.Hubs.Dto;
using api.Modules.Hubs.Entity;
using api.Modules.Stocks.Dto;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.Hubs;

public static class HubService
{
  /// <summary>
  /// Creates a new hub.
  /// </summary>
  public static async Task<ResponseHubDTO> CreateHub(
    RequestCreateHubDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (string.IsNullOrWhiteSpace(request.Name) || string.IsNullOrWhiteSpace(request.City))
    {
      return new ResponseHubDTO(
        HttpStatusCode.BadRequest,
        null,
        "Name and City are required fields.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      // Check if an hub with this name already exists
      var existingBank = await context.Hubs.AsNoTracking()
        .AnyAsync(b => b.Name.ToLower() == request.Name.ToLower(), ct);

      if (existingBank)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseHubDTO(
          HttpStatusCode.Conflict,
          null,
          $"hub with name '{request.Name}' already exists.");
      }

      var newBank = new Hub(request.Name, request.City);

      context.Hubs.Add(newBank);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseHubDTO(HttpStatusCode.Created, MapToResponseEntityHubDto(newBank),
        "hub created successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error creating hub: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseHubDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while creating the hub.");
    }
  }

  /// <summary>
  /// Retrieves a single hub by its ID.
  /// </summary>
  public static async Task<ResponseHubDTO> GetHub(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    var Hub = await context.Hubs.AsNoTracking()
      .Include(b => b.Stocks) // Include related stocks
      .SingleOrDefaultAsync(b => b.Id == id, ct);

    if (Hub == null)
    {
      return new ResponseHubDTO(HttpStatusCode.NotFound, null, $"hub with ID '{id}' not found.");
    }

    var responseBank = MapToResponseEntityHubDto(Hub);
    return new ResponseHubDTO(HttpStatusCode.OK, responseBank, "hub retrieved successfully.");
  }

  /// <summary>
  /// Retrieves a list of all hubs.
  /// </summary>
  public static async Task<ResponseHubListDTO> GetHubs(
    ApiDbContext context,
    CancellationToken ct)
  {
    var Hubs = await context.Hubs.AsNoTracking()
      .Select(b => MapToResponseEntityHubDto(b)) // Use mapping helper
      .ToListAsync(ct);

    // Return 200 OK with an empty list if no banks are found, not 404
    return new ResponseHubListDTO(HttpStatusCode.OK, Hubs.Count, Hubs,
      "hubs retrieved successfully.");
  }

  /// <summary>
  /// Updates an existing hub's information.
  /// </summary>
  public static async Task<ResponseHubDTO> UpdateHub(
    Guid id,
    RequestUpdateHubDto request,
    ApiDbContext context,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseHubDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var Hub = await context.Hubs
        .SingleOrDefaultAsync(b => b.Id == id, ct);

      if (Hub == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseHubDTO(HttpStatusCode.NotFound, null,
          $"hub with ID '{id}' not found.");
      }

      // Only update if the request property is not null/empty AND different from current value
      if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != Hub.Name)
      {
        // Check for duplicate name if it's being changed
        var existingBankWithSameName = await context.Hubs.AsNoTracking()
          .AnyAsync(b => b.Name.ToLower() == request.Name.ToLower() && b.Id != id, ct);

        if (existingBankWithSameName)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseHubDTO(HttpStatusCode.Conflict, null,
            $"hub with name '{request.Name}' already exists.");
        }

        Hub.SetName(request.Name);
      }

      if (!string.IsNullOrWhiteSpace(request.City))
      {
        Hub.SetCity(request.City);
      }

      Hub.UpdateTimestamps(); // Assuming this updates the ModifiedAt timestamp

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      return new ResponseHubDTO(HttpStatusCode.OK, MapToResponseEntityHubDto(Hub),
        "hub updated successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error updating hub: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseHubDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while updating the hub.");
    }
  }

  /// <summary>
  /// Deletes an hub from the database.
  /// </summary>
  public static async Task<ResponseHubDTO> DeleteHub(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    await using var transaction = await context.Database.BeginTransactionAsync(ct);
    try
    {
      var Hub = await context.Hubs
        .Include(b => b.Stocks) // Include related stocks if needed for business rules
        .SingleOrDefaultAsync(b => b.Id == id, ct);

      if (Hub == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseHubDTO(HttpStatusCode.NotFound, null,
          $"hub with ID '{id}' not found.");
      }


      if (Hub.Stocks.Any())
      {
        await transaction.RollbackAsync(ct);
        return new ResponseHubDTO(HttpStatusCode.BadRequest, null,
          $"hub with ID '{id}' cannot be deleted because it has associated stock/items.");
      }


      context.Hubs.Remove(Hub);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // 204 No Content is standard for successful DELETE operations where no content is returned
      return new ResponseHubDTO(HttpStatusCode.OK, null, "hub deleted successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error deleting hub: {ex.Message} - {ex.InnerException?.Message}");
      return new ResponseHubDTO(HttpStatusCode.InternalServerError, null,
        "An unexpected error occurred while deleting the hub.");
    }
  }

  /// <summary>
  /// Maps an Hub entity to a ResponseEntityHubDTO.
  /// </summary>
  private static ResponseEntityHubDTO MapToResponseEntityHubDto(Hub Hub)
  {
    return new ResponseEntityHubDTO(
      Hub.Id,
      Hub.Name,
      Hub.City,
      Hub.Stocks.Select(s => new ResponseEntityStockDTO(
        s.Id,
        s.Title,
        s.ImageUrl,
        s.MaintenanceQtd,
        s.AvailableQtd,
        s.BorrowedQtd,
        s.TotalQtd,
        s.HubId,
        null,
        null,
        s.CreatedAt
      )).ToArray(),
      Hub.CreatedAt
    );
  }
}