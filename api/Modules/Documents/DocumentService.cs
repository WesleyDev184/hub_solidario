namespace api.Modules.Documents;

using System.Net;
using DB;
using Dto;
using Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using api.Services.S3;

public static class DocumentService
{
  // Método para mapear Document para ResponseEntityDocumentsDTO
  private static ResponseEntityDocumentsDTO MapToResponseEntityDocumentsDto(Document document)
  {
    return new ResponseEntityDocumentsDTO(
      document.Id,
      document.OriginalFileName,
      document.StorageUrl,
      document.ApplicantId,
      document.DependentId,
      document.CreatedAt,
      document.UpdatedAt
    );
  }

  // Criar um novo documento
  public static async Task<ResponseControllerDocumentsDTO> CreateDocument(
    RequestCreateDocumentDto request,
    string documentUrl,
    ApiDbContext context,
    CancellationToken ct)
  {
    await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);

    try
    {
      // Verificar se o applicant existe
      bool applicantExists = await context.Applicants.AsNoTracking().AnyAsync(a => a.Id == request.ApplicantId, ct);
      if (!applicantExists)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseControllerDocumentsDTO(HttpStatusCode.BadRequest, null, "Applicant not found.");
      }

      // Verificar se o dependent existe (se fornecido)
      if (request.DependentId.HasValue)
      {
        bool dependentExists = await context.Dependents.AsNoTracking().AnyAsync(d => d.Id == request.DependentId.Value, ct);
        if (!dependentExists)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseControllerDocumentsDTO(HttpStatusCode.BadRequest, null, "Dependent not found.");
        }
      }

      // Criar o documento
      var document = new Document(
        request.DocumentFile.FileName,
        documentUrl,
        request.ApplicantId,
        request.DependentId
      );

      context.Documents.Add(document);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      ResponseEntityDocumentsDTO documentDto = MapToResponseEntityDocumentsDto(document);
      return new ResponseControllerDocumentsDTO(HttpStatusCode.Created, documentDto, "Document created successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error creating document: {ex.Message}");
      return new ResponseControllerDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while creating the document.");
    }
  }

  // Buscar documento por ID
  public static async Task<ResponseControllerDocumentsDTO> GetDocumentById(
    Guid id,
    ApiDbContext context,
    CancellationToken ct)
  {
    try
    {
      Document? document = await context.Documents
        .AsNoTracking()
        .SingleOrDefaultAsync(d => d.Id == id, ct);

      if (document == null)
      {
        return new ResponseControllerDocumentsDTO(HttpStatusCode.NotFound, null, "Document not found.");
      }

      ResponseEntityDocumentsDTO documentDto = MapToResponseEntityDocumentsDto(document);
      return new ResponseControllerDocumentsDTO(HttpStatusCode.OK, documentDto, "Document retrieved successfully.");
    }
    catch (Exception ex)
    {
      Console.WriteLine($"Error retrieving document: {ex.Message}");
      return new ResponseControllerDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while retrieving the document.");
    }
  }

  // Listar documentos por applicant
  public static async Task<ResponseDocumentsDTO> GetDocumentsByApplicant(
    Guid applicantId,
    ApiDbContext context,
    CancellationToken ct)
  {
    try
    {
      // Verificar se o applicant existe
      bool applicantExists = await context.Applicants.AnyAsync(a => a.Id == applicantId, ct);
      if (!applicantExists)
      {
        return new ResponseDocumentsDTO(HttpStatusCode.NotFound, null, "Applicant not found.");
      }

      List<Document> documents = await context.Documents
        .Where(d => d.ApplicantId == applicantId)
        .OrderByDescending(d => d.CreatedAt)
        .AsNoTracking()
        .ToListAsync(ct);

      List<ResponseEntityDocumentsDTO> documentsDto = documents
        .Select(MapToResponseEntityDocumentsDto)
        .ToList();

      return new ResponseDocumentsDTO(HttpStatusCode.OK, documentsDto, "Documents retrieved successfully.");
    }
    catch (Exception ex)
    {
      Console.WriteLine($"Error retrieving documents by applicant: {ex.Message}");
      return new ResponseDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while retrieving documents.");
    }
  }

  // Listar documentos por dependent
  public static async Task<ResponseDocumentsDTO> GetDocumentsByDependent(
    Guid dependentId,
    ApiDbContext context,
    CancellationToken ct)
  {
    try
    {
      // Verificar se o dependent existe
      bool dependentExists = await context.Dependents.AnyAsync(d => d.Id == dependentId, ct);
      if (!dependentExists)
      {
        return new ResponseDocumentsDTO(HttpStatusCode.NotFound, null, "Dependent not found.");
      }

      List<Document> documents = await context.Documents
        .Where(d => d.DependentId == dependentId)
        .AsNoTracking()
        .OrderByDescending(d => d.CreatedAt)
        .ToListAsync(ct);

      List<ResponseEntityDocumentsDTO> documentsDto = documents
        .Select(MapToResponseEntityDocumentsDto)
        .ToList();

      return new ResponseDocumentsDTO(HttpStatusCode.OK, documentsDto, "Documents retrieved successfully.");
    }
    catch (Exception ex)
    {
      Console.WriteLine($"Error retrieving documents by dependent: {ex.Message}");
      return new ResponseDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while retrieving documents.");
    }
  }

  // Atualizar documento
  public static async Task<ResponseControllerDocumentsDTO> UpdateDocument(
    Guid id,
    RequestUpdateDocumentDto? request,
    ApiDbContext context,
    IFileStorageService fileStorageService,
    string? newDocumentUrl,
    CancellationToken ct)
  {
    if (request == null)
    {
      return new ResponseControllerDocumentsDTO(HttpStatusCode.BadRequest, null, "Invalid request data provided.");
    }

    await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);
    string? oldDocumentUrl = null;

    try
    {
      Document? document = await context.Documents.SingleOrDefaultAsync(d => d.Id == id, ct);

      if (document == null)
      {
        await transaction.RollbackAsync(ct);
        // Se fez upload de novo documento, deleta do storage
        if (!string.IsNullOrEmpty(newDocumentUrl))
        {
          try
          {
            var fileName = newDocumentUrl.Split('/').Last();
            await fileStorageService.DeleteFileAsync(fileName);
          }
          catch (Exception ex)
          {
            Console.WriteLine($"Warning: Failed to delete uploaded document after rollback: {ex.Message}");
          }
        }
        return new ResponseControllerDocumentsDTO(HttpStatusCode.NotFound, null, "Document not found.");
      }

      // Armazenar URL antiga para possível cleanup
      oldDocumentUrl = document.StorageUrl;

      // Verificar se o dependent existe (se fornecido)
      if (request.DependentId.HasValue)
      {
        bool dependentExists = await context.Dependents.AnyAsync(d => d.Id == request.DependentId.Value, ct);
        if (!dependentExists)
        {
          await transaction.RollbackAsync(ct);
          return new ResponseControllerDocumentsDTO(HttpStatusCode.BadRequest, null, "Dependent not found.");
        }
        document.SetDependentId(request.DependentId);
      }

      // Atualizar documento se veio novo
      if (!string.IsNullOrEmpty(newDocumentUrl))
      {
        document.SetStorageUrl(newDocumentUrl);
        if (request.DocumentFile != null)
        {
          document.SetOriginalFileName(request.DocumentFile.FileName);
        }
      }

      document.UpdateTimestamps();

      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // Se houve novo documento, deleta o antigo
      if (!string.IsNullOrEmpty(newDocumentUrl) && !string.IsNullOrEmpty(oldDocumentUrl))
      {
        try
        {
          var oldFileName = oldDocumentUrl.Split('/').Last();
          await fileStorageService.DeleteFileAsync(oldFileName);
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Warning: Failed to delete old document: {ex.Message}");
        }
      }

      ResponseEntityDocumentsDTO updatedDocumentDto = MapToResponseEntityDocumentsDto(document);
      return new ResponseControllerDocumentsDTO(HttpStatusCode.OK, updatedDocumentDto, "Document updated successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error updating document: {ex.Message}");
      return new ResponseControllerDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while updating the document.");
    }
  }

  // Deletar documento
  public static async Task<ResponseControllerDocumentsDTO> DeleteDocument(
    Guid id,
    ApiDbContext context,
    IFileStorageService fileStorageService,
    CancellationToken ct)
  {
    await using IDbContextTransaction transaction = await context.Database.BeginTransactionAsync(ct);

    try
    {
      Document? document = await context.Documents.SingleOrDefaultAsync(d => d.Id == id, ct);

      if (document == null)
      {
        await transaction.RollbackAsync(ct);
        return new ResponseControllerDocumentsDTO(HttpStatusCode.NotFound, null, "Document not found.");
      }

      var documentUrl = document.StorageUrl;

      context.Documents.Remove(document);
      await context.SaveChangesAsync(ct);
      await transaction.CommitAsync(ct);

      // Deletar arquivo do storage
      if (!string.IsNullOrEmpty(documentUrl))
      {
        try
        {
          var fileName = documentUrl.Split('/').Last();
          await fileStorageService.DeleteFileAsync(fileName);
        }
        catch (Exception ex)
        {
          Console.WriteLine($"Warning: Failed to delete document from storage: {ex.Message}");
        }
      }

      return new ResponseControllerDocumentsDTO(HttpStatusCode.OK, null, "Document deleted successfully.");
    }
    catch (Exception ex)
    {
      await transaction.RollbackAsync(ct);
      Console.WriteLine($"Error deleting document: {ex.Message}");
      return new ResponseControllerDocumentsDTO(HttpStatusCode.InternalServerError, null, "An unexpected error occurred while deleting the document.");
    }
  }
}
