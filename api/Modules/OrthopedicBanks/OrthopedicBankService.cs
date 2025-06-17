using System;
using System.Net;
using api.DB;
using api.Modules.OrthopedicBanks.Dto;
using api.Modules.OrthopedicBanks.Entity;
using Microsoft.EntityFrameworkCore;

namespace api.Modules.OrthopedicBanks;

public static class OrthopedicBankService
{

  public static async Task<ResponseOrthopedicBankDTO> CreateOrthopedicBank(
        RequestCreateOrthopedicBankDto request,
        ApiDbContext context,
        CancellationToken ct)
  {
    if (string.IsNullOrWhiteSpace(request.Name) ||
        string.IsNullOrWhiteSpace(request.City))
    {
      return new ResponseOrthopedicBankDTO(
          HttpStatusCode.BadRequest,
          null,
          "All fields are required");
    }

    // Verifica se já existe um banco ortopédico com este nome, ativo ou inativo
    var existingBank = await context.OrthopedicBanks
        .AnyAsync(b => b.Name == request.Name, ct);

    if (existingBank)
    {
      return new ResponseOrthopedicBankDTO(
            HttpStatusCode.Conflict,
            null,
            "Orthopedic bank with this name already exists and is active");
    }

    // Cria um novo banco ortopédico
    var newBank = new OrthopedicBank(
        request.Name,
        request.City
        );

    context.OrthopedicBanks.Add(newBank);
    await context.SaveChangesAsync(ct);

    var responseNewBank = new ResponseEntityOrthopedicBankDTO(
        newBank.Id,
        newBank.Name,
        newBank.City,
        newBank.CreatedAt);

    return new ResponseOrthopedicBankDTO(HttpStatusCode.Created, responseNewBank, "Orthopedic bank created successfully");
  }

  public static async Task<ResponseOrthopedicBankDTO> GetOrthopedicBank(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
  {
    var orthopedicBank = await context.OrthopedicBanks
        .SingleOrDefaultAsync(b => b.Id == id, ct);

    if (orthopedicBank == null)
    {
      return new ResponseOrthopedicBankDTO(
          HttpStatusCode.NotFound,
          null,
          "Orthopedic bank not found");
    }

    var responseBank = new ResponseEntityOrthopedicBankDTO(
        orthopedicBank.Id,
        orthopedicBank.Name,
        orthopedicBank.City,
        orthopedicBank.CreatedAt);

    return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, responseBank, "Orthopedic bank retrieved successfully");
  }

  public static async Task<ResponseOrthopedicBankListDTO> GetOrthopedicBanks(
        ApiDbContext context,
        CancellationToken ct)
  {
    var orthopedicBanks = await context.OrthopedicBanks.Select(b => new ResponseEntityOrthopedicBankDTO(
        b.Id,
        b.Name,
        b.City,
        b.CreatedAt))
        .ToListAsync(ct);

    if (orthopedicBanks.Count == 0)
    {
      return new ResponseOrthopedicBankListDTO(
          HttpStatusCode.NotFound,
          0,
          null,
          "No orthopedic banks found");
    }

    return new ResponseOrthopedicBankListDTO(HttpStatusCode.OK, orthopedicBanks.Count, orthopedicBanks, "Orthopedic banks retrieved successfully");
  }

  public static async Task<ResponseOrthopedicBankDTO> UpdateOrthopedicBank(
        Guid id,
        RequestUpdateOrthopedicBankDto request,
        ApiDbContext context,
        CancellationToken ct)
  {
    var orthopedicBank = await context.OrthopedicBanks
        .SingleOrDefaultAsync(b => b.Id == id, ct);

    if (orthopedicBank == null)
    {
      return new ResponseOrthopedicBankDTO(
          HttpStatusCode.NotFound,
          null,
          "Orthopedic bank not found");
    }

    if (!string.IsNullOrWhiteSpace(request.Name))
    {
      orthopedicBank.SetName(request.Name);
    }

    if (!string.IsNullOrWhiteSpace(request.City))
    {
      orthopedicBank.SetCity(request.City);
    }

    orthopedicBank.UpdateTimestamps();

    await context.SaveChangesAsync(ct);

    var responseUpdatedBank = new ResponseEntityOrthopedicBankDTO(
        orthopedicBank.Id,
        orthopedicBank.Name,
        orthopedicBank.City,
        orthopedicBank.CreatedAt);

    return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, responseUpdatedBank, "Orthopedic bank updated successfully");
  }

  public static async Task<ResponseOrthopedicBankDTO> DeleteOrthopedicBank(
        Guid id,
        ApiDbContext context,
        CancellationToken ct)
  {
    var orthopedicBank = await context.OrthopedicBanks
        .SingleOrDefaultAsync(b => b.Id == id, ct);

    if (orthopedicBank == null)
    {
      return new ResponseOrthopedicBankDTO(
          HttpStatusCode.NotFound,
          null,
          "Orthopedic bank not found");
    }


    context.OrthopedicBanks.Remove(orthopedicBank);
    await context.SaveChangesAsync(ct);

    var responseDeletedBank = new ResponseEntityOrthopedicBankDTO(
        orthopedicBank.Id,
        orthopedicBank.Name,
        orthopedicBank.City,
        orthopedicBank.CreatedAt);

    return new ResponseOrthopedicBankDTO(HttpStatusCode.OK, responseDeletedBank, "Orthopedic bank deleted successfully");
  }

}
