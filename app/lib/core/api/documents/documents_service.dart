import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/documents/controllers/documents_controller.dart';
import 'package:app/core/api/documents/repositories/documents_repository.dart';
import 'package:app/core/api/documents/services/documents_cache_service.dart';
import 'package:get/get.dart';

/// Serviço principal para operações de documentos
class DocumentsService {
  static DocumentsService? _instance;

  late final DocumentsController documentsController;
  final ApiClient apiClient;

  DocumentsService._internal(this.apiClient);

  static DocumentsService get instance {
    if (_instance == null) {
      throw Exception(
        'DocumentsService não inicializado. Chame initialize() primeiro.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = DocumentsService._internal(apiClient);
    final cacheService = DocumentsCacheService();
    await cacheService.initialize();

    final repository = DocumentsRepository(apiClient);
    service.documentsController = DocumentsController(
      repository: repository,
      cacheService: cacheService,
    );
    Get.put<DocumentsController>(service.documentsController, permanent: true);
    _instance = service;
  }
}
