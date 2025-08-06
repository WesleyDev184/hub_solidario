import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/api_config.dart';
import 'package:app/core/api/documents/models/documents_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de documentos na API
class DocumentsRepository {
  final ApiClient _apiClient;

  const DocumentsRepository(this._apiClient);

  /// Busca todos os documentos
  AsyncResult<List<Document>> getDocuments(String applicantId) async {
    try {
      final result = await _apiClient.get(
        ApiEndpoints.documentsByApplicant(applicantId),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = DocumentListResponse.fromJson(data);
          if (response.success) {
            return Success(response.data);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao buscar documentos'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos documentos: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um documento por ID
  AsyncResult<Document> getDocument(String documentId) async {
    try {
      final result = await _apiClient.get(
        ApiEndpoints.documentById(documentId),
        useAuth: true,
      );
      return result.fold((data) {
        try {
          final response = DocumentResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Documento não encontrado'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do documento: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo documento via multipart (suporte a arquivo)
  AsyncResult<Document> createDocument(CreateDocumentRequest request) async {
    try {
      final result = await _apiClient.postMultipart(
        ApiEndpoints.documents,
        request.toJson(),
        file: request.documentFile,
        bytes: request.documentBytes,
        fileName: request.documentFileName,
        useAuth: true,
      );
      return result.fold((data) {
        try {
          final response = DocumentResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao criar documento'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do documento: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um documento via multipart (suporte a arquivo)
  AsyncResult<Document> updateDocument(
    String documentId,
    UpdateDocumentRequest request,
  ) async {
    try {
      final result = await _apiClient.postMultipart(
        ApiEndpoints.documentById(documentId),
        request.toJson(),
        file: request.documentFile,
        bytes: request.documentBytes,
        fileName: request.documentFileName,
        useAuth: true,
      );
      return result.fold((data) {
        try {
          final response = DocumentResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao atualizar documento'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do documento: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um documento
  AsyncResult<bool> deleteDocument(String documentId) async {
    try {
      final result = await _apiClient.delete(
        ApiEndpoints.documentById(documentId),
        useAuth: true,
      );
      return result.fold((data) {
        try {
          // Sucesso se status 200
          return Success(true);
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }
}
