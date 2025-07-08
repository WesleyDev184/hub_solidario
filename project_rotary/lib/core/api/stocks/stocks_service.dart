import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/stocks/controllers/stocks_controller.dart';
import 'package:project_rotary/core/api/stocks/models/stocks_models.dart';
import 'package:project_rotary/core/api/stocks/repositories/stocks_repository.dart';
import 'package:project_rotary/core/api/stocks/services/stocks_cache_service.dart';
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

  /// Carrega todos os stocks
  static AsyncResult<List<Stock>> getStocks({bool forceRefresh = false}) async {
    await ensureInitialized();
    return _instance!.loadStocks(forceRefresh: forceRefresh);
  }

  /// Busca stocks por banco ortopédico
  static AsyncResult<List<Stock>> getStocksByOrthopedicBank(
    String orthopedicBankId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadStocksByOrthopedicBank(
      orthopedicBankId,
      forceRefresh: forceRefresh,
    );
  }

  /// Busca um stock por ID
  static AsyncResult<Stock> getStock(
    String stockId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getStock(stockId, forceRefresh: forceRefresh);
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

  /// Deleta um stock
  static AsyncResult<bool> deleteStock(String stockId) async {
    await ensureInitialized();
    return _instance!.deleteStock(stockId);
  }

  /// Busca stocks por título
  static List<Stock> searchStocksByTitle(String query) {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.searchStocksByTitle(query);
  }

  /// Obtém stocks disponíveis
  static List<Stock> getAvailableStocks() {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.getAvailableStocks();
  }

  /// Obtém stocks de um banco específico
  static List<Stock> getStocksByBank(String orthopedicBankId) {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.getStocksByBank(orthopedicBankId);
  }

  /// Obtém estatísticas dos stocks
  static Map<String, int> getStocksStatistics() {
    if (!_isInitialized || _instance == null) {
      return {
        'totalStocks': 0,
        'availableStocks': 0,
        'totalItems': 0,
        'availableItems': 0,
        'borrowedItems': 0,
        'maintenanceItems': 0,
      };
    }
    return _instance!.getStocksStatistics();
  }

  /// Verifica se um stock está disponível
  static bool isStockAvailable(String stockId) {
    if (!_isInitialized || _instance == null) return false;
    try {
      return _instance!.isStockAvailable(stockId);
    } catch (e) {
      return false;
    }
  }

  /// Obtém a quantidade disponível de um stock
  static int getAvailableQuantity(String stockId) {
    if (!_isInitialized || _instance == null) return 0;
    try {
      return _instance!.getAvailableQuantity(stockId);
    } catch (e) {
      return 0;
    }
  }

  /// Força atualização dos dados
  static AsyncResult<List<Stock>> refreshStocks() async {
    await ensureInitialized();
    return _instance!.refreshStocks();
  }

  /// Limpa todos os dados
  static Future<void> clearData() async {
    if (_instance != null) {
      await _instance!.clearData();
    }
  }

  // === GETTERS DE ESTADO ===

  /// Lista de stocks atual
  static List<Stock> get currentStocks {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.stocks;
  }

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

  /// Verifica se tem dados carregados
  static bool get hasData {
    if (!_isInitialized || _instance == null) return false;
    return _instance!.hasData;
  }
}
