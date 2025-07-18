import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/applicants/controllers/applicants_controller.dart';
import 'package:app/core/api/applicants/repositories/applicants_repository.dart';
import 'package:app/core/api/applicants/services/applicants_cache_service.dart';
import 'package:get/get.dart';

/// Serviço principal para operações de applicants e dependents
class ApplicantsService {
  static ApplicantsService? _instance;

  late final ApplicantsController applicantsController;
  final ApiClient apiClient;

  ApplicantsService._internal(this.apiClient);

  static ApplicantsService get instance {
    if (_instance == null) {
      throw Exception(
        'ApplicantsService não inicializado. Chame initialize() primeiro.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = ApplicantsService._internal(apiClient);
    final cacheService = ApplicantsCacheService();
    await cacheService.initialize();
    final repository = ApplicantsRepository(apiClient);
    service.applicantsController = ApplicantsController(
      repository,
      cacheService,
    );
    Get.put<ApplicantsController>(
      service.applicantsController,
      permanent: true,
    );
    _instance = service;
  }
}
