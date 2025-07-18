import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/loans/controllers/loans_controller.dart';
import 'package:app/core/api/loans/repositories/loans_repository.dart';
import 'package:app/core/api/loans/services/loans_cache_service.dart';
import 'package:get/get.dart';

/// Serviço principal para operações de loans
class LoansService {
  static LoansService? _instance;

  late final LoansController loansController;
  final ApiClient apiClient;

  LoansService._internal(this.apiClient);

  static LoansService get instance {
    if (_instance == null) {
      throw Exception(
        'LoansService não inicializado. Chame initialize() primeiro.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = LoansService._internal(apiClient);
    final cacheService = LoansCacheService();

    await cacheService.initialize();

    final repository = LoansRepository(apiClient);
    service.loansController = LoansController(repository, cacheService);

    Get.put<LoansController>(service.loansController, permanent: true);
    _instance = service;
  }
}
