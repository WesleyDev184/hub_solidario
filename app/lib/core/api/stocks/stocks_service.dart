import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/api/stocks/repositories/stocks_repository.dart';
import 'package:app/core/api/stocks/services/stocks_cache_service.dart';
import 'package:get/get.dart';

/// Serviço principal para operações de stocks

class StocksService {
  static StocksService? _instance;

  late final StocksController stocksController;
  final ApiClient apiClient;

  StocksService._internal(this.apiClient);

  static StocksService get instance {
    if (_instance == null) {
      throw Exception(
        'StocksService não inicializado. Chame initialize() primeiro.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = StocksService._internal(apiClient);
    final cacheService = StocksCacheService();
    await cacheService.initialize();

    final repository = StocksRepository(apiClient);
    service.stocksController = StocksController(
      repository: repository,
      cacheService: cacheService,
    );
    Get.put<StocksController>(service.stocksController, permanent: true);
    _instance = service;
  }
}
