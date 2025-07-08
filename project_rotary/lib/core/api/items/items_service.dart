import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/items/controllers/items_controller.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';
import 'package:project_rotary/core/api/items/repositories/items_repository.dart';
import 'package:project_rotary/core/api/items/services/items_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço principal para operações de items (itens de estoque)
class ItemsService {
  static ItemsController? _instance;
  static bool _isInitialized = false;

  /// Inicializa o serviço de items
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_isInitialized) return;

    try {
      final cacheService = ItemsCacheService();
      await cacheService.initialize();

      final repository = ItemsRepository(apiClient);
      final controller = ItemsController(repository, cacheService);

      _instance = controller;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar ItemsService: $e');
    }
  }

  /// Verifica se o serviço está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém a instância do controller
  static ItemsController? get instance => _instance;

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      throw Exception(
        'ItemsService não foi inicializado. Chame ItemsService.initialize() primeiro.',
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

  /// Carrega todos os items
  static AsyncResult<List<Item>> getItems({bool forceRefresh = false}) async {
    await ensureInitialized();
    return _instance!.loadItems(forceRefresh: forceRefresh);
  }

  /// Busca items por stock
  static AsyncResult<List<Item>> getItemsByStock(
    String stockId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadItemsByStock(stockId, forceRefresh: forceRefresh);
  }

  /// Busca um item por ID
  static AsyncResult<Item> getItem(
    String itemId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getItem(itemId, forceRefresh: forceRefresh);
  }

  /// Cria um novo item
  static AsyncResult<String> createItem(CreateItemRequest request) async {
    await ensureInitialized();
    return _instance!.createItem(request);
  }

  /// Atualiza um item existente
  static AsyncResult<Item> updateItem(
    String itemId,
    UpdateItemRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateItem(itemId, request);
  }

  /// Deleta um item
  static AsyncResult<bool> deleteItem(String itemId) async {
    await ensureInitialized();
    return _instance!.deleteItem(itemId);
  }

  /// Busca items com filtros
  static AsyncResult<List<Item>> searchItems({
    ItemStatus? status,
    String? stockId,
    int? minSeriaCode,
    int? maxSeriaCode,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();

    // Cria filtros baseado nos parâmetros
    final filters = ItemFilters(
      status: status,
      stockId: stockId,
      minSeriaCode: minSeriaCode,
      maxSeriaCode: maxSeriaCode,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
    );

    return _instance!.loadItems(forceRefresh: forceRefresh, filters: filters);
  }

  /// Obtém items disponíveis (status = available)
  static AsyncResult<List<Item>> getAvailableItems({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getAvailableItems(forceRefresh: forceRefresh);
  }

  /// Obtém items em manutenção (status = maintenance)
  static AsyncResult<List<Item>> getMaintenanceItems({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getMaintenanceItems(forceRefresh: forceRefresh);
  }

  /// Obtém estatísticas dos items
  static Map<String, int> getItemsStatistics() {
    if (!_isInitialized || _instance == null) {
      return {};
    }
    return _instance!.getItemsStatistics();
  }

  /// Obtém estatísticas por stock
  static Map<String, Map<String, int>> getStatisticsByStock() {
    if (!_isInitialized || _instance == null) {
      return {};
    }
    return _instance!.getStatisticsByStock();
  }

  /// Busca items por faixa de serial code (método local)
  static List<Item> getItemsBySerialRange(int minCode, int maxCode) {
    if (!_isInitialized || _instance == null) {
      return [];
    }
    return _instance!.getItemsBySerialRange(minCode, maxCode);
  }

  /// Atualiza status de um item
  static AsyncResult<Item> updateItemStatus(
    String itemId,
    ItemStatus newStatus,
  ) async {
    await ensureInitialized();
    return _instance!.updateItemStatus(itemId, newStatus);
  }

  /// Atualiza código serial de um item
  static AsyncResult<Item> updateItemSerialCode(
    String itemId,
    int newSerialCode,
  ) async {
    await ensureInitialized();
    return _instance!.updateItemSerialCode(itemId, newSerialCode);
  }

  /// Verifica se um item específico está disponível
  static bool isItemAvailable(String itemId) {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.isItemAvailable(itemId);
  }

  /// Obtém o status de um item
  static ItemStatus? getItemStatus(String itemId) {
    if (!_isInitialized || _instance == null) {
      return null;
    }
    return _instance!.getItemStatus(itemId);
  }

  /// Obtém o código serial de um item
  static int? getItemSerialCode(String itemId) {
    if (!_isInitialized || _instance == null) {
      return null;
    }
    return _instance!.getItemSerialCode(itemId);
  }

  /// Limpa cache de items
  static Future<void> clearCache() async {
    await ensureInitialized();
    return _instance!.clearData();
  }

  /// Força atualização do cache
  static AsyncResult<List<Item>> refreshCache() async {
    await ensureInitialized();
    return _instance!.refreshItems();
  }
}
