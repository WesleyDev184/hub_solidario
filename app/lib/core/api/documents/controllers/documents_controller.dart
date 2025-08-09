import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/documents/models/documents_models.dart';
import 'package:app/core/api/documents/repositories/documents_repository.dart';
import 'package:app/core/api/documents/services/documents_cache_service.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de documentos
class DocumentsController extends GetxController {
  late final DocumentsRepository repository;
  late final DocumentsCacheService cacheService;
  final AuthController authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  DocumentsController({required this.repository, required this.cacheService});

  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  set error(String? value) {
    _error.value = value ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    ever(authController.stateRx, (authState) async {
      if (!authState.isAuthenticated) {
        await clearData();
      }
    });
  }

  AsyncResult<List<Document>> loadDocuments(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading.value = true;
      if (!forceRefresh) {
        final cachedDocs = await cacheService.getCachedDocuments(applicantId);
        if (cachedDocs != null) {
          _isLoading.value = false;
          return Success(cachedDocs);
        }
      }

      final result = await repository.getDocuments(applicantId);
      return result.fold(
        (docs) async {
          await cacheService.cacheDocuments(applicantId, docs);
          _isLoading.value = false;
          return Success(docs);
        },
        (error) {
          _isLoading.value = false;
          this.error = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      error = e.toString();
      return Failure(Exception('Erro ao carregar documentos: $e'));
    }
  }

  AsyncResult<Document> loadDocument(
    String documentId,
    String applicantId,
  ) async {
    try {
      _isLoading.value = true;
      final cachedDoc = await cacheService.getCachedDocument(
        documentId,
        applicantId,
      );
      if (cachedDoc != null) {
        _isLoading.value = false;
        return Success(cachedDoc);
      }

      final result = await repository.getDocument(documentId);
      return result.fold(
        (doc) async {
          await cacheService.cacheDocument(doc.applicantId, doc);
          _isLoading.value = false;
          return Success(doc);
        },
        (error) {
          _isLoading.value = false;
          this.error = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      error = e.toString();
      return Failure(Exception('Erro ao carregar documento: $e'));
    }
  }

  AsyncResult<Document> createDocument(CreateDocumentRequest request) async {
    try {
      _isLoading.value = true;
      final result = await repository.createDocument(request);
      return result.fold(
        (doc) async {
          await cacheService.cacheDocument(request.applicantId, doc);
          _isLoading.value = false;
          return Success(doc);
        },
        (error) {
          _isLoading.value = false;
          this.error = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      error = e.toString();
      return Failure(Exception('Erro ao criar documento: $e'));
    }
  }

  AsyncResult<Document> updateDocument(
    String applicantId,
    String documentId,
    UpdateDocumentRequest request,
  ) async {
    try {
      _isLoading.value = true;
      final result = await repository.updateDocument(documentId, request);
      return result.fold(
        (doc) async {
          await cacheService.updateDocument(applicantId, doc);
          _isLoading.value = false;
          return Success(doc);
        },
        (error) {
          _isLoading.value = false;
          this.error = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      error = e.toString();
      return Failure(Exception('Erro ao atualizar documento: $e'));
    }
  }

  AsyncResult<void> deleteDocument(
    String applicantId,
    String documentId,
  ) async {
    try {
      _isLoading.value = true;
      final result = await repository.deleteDocument(documentId);
      return result.fold(
        (success) async {
          await cacheService.deleteDocument(applicantId, documentId);
          _isLoading.value = false;
          return Success(success);
        },
        (error) {
          _isLoading.value = false;
          this.error = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading.value = false;
      error = e.toString();
      return Failure(Exception('Erro ao deletar documento: $e'));
    }
  }

  Future<void> clearData() async {
    await cacheService.clearAllCache();
  }
}
