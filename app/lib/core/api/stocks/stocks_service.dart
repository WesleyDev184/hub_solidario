import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/api/stocks/models/stocks_models.dart';
import 'package:app/core/api/stocks/repositories/stocks_repository.dart';
import 'package:app/core/api/stocks/services/stocks_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço principal para operações de stocks
class StocksService {
  static StocksController? _instance;
  static bool _isInitialized = false;

  /// Inicializa o serviço de stocks
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_isInitialized) return;

    try {
      final cacheService = StocksCacheService();
      await cacheService.initialize();

      final repository = StocksRepository(apiClient);
      final controller = StocksController(repository, cacheService);

      _instance = controller;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar StocksService: $e');
    }
  }

  /// Verifica se o serviço está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém a instância do controller
  static StocksController? get instance => _instance;

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      throw Exception(
        'StocksService não foi inicializado. Chame StocksService.initialize() primeiro.',
      );
    }
  }

  /// Reinicializa o serviço
  static Future<void> reinitialize({required ApiClient apiClient}) async {
    _isInitialized = false;
    _instance = null;
    await initialize(apiClient: apiClient);
  }

  /// Encerra o serviço
  static Future<void> dispose() async {
    if (_instance != null) {
      await _instance!.clearData();
    }
    _instance = null;
    _isInitialized = false;
  }

  // === MÉTODOS DE CONVENIÊNCIA ===

  /// Busca stocks por banco ortopédico
  static AsyncResult<List<Stock>> getStocksByOrthopedicBank({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadStocksByOrthopedicBank(forceRefresh: forceRefresh);
  }

  /// Cria um novo stock
  static AsyncResult<String> createStock(CreateStockRequest request) async {
    await ensureInitialized();
    return _instance!.createStock(request);
  }

  /// Atualiza um stock existente
  static AsyncResult<Stock> updateStock(
    String stockId,
    UpdateStockRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateStock(stockId, request);
  }

  /// Atualiza o cache de um stock
  static Future<void> cacheStock(Stock stock) async {
    await ensureInitialized();
    return _instance!.cacheStock(stock);
  }

  /// Deleta um stock
  static AsyncResult<bool> deleteStock(String stockId) async {
    await ensureInitialized();
    return _instance!.deleteStock(stockId);
  }

  /// Limpa todos os dados
  static Future<void> clearData() async {
    if (_instance != null) {
      await _instance!.clearData();
    }
  }

  // === GETTERS DE ESTADO ===

  /// Indica se está carregando
  static bool get isLoading {
    if (!_isInitialized || _instance == null) return false;
    return _instance!.isLoading;
  }

  /// Mensagem de erro, se houver
  static String? get error {
    if (!_isInitialized || _instance == null) return null;
    return _instance!.error;
  }
}
