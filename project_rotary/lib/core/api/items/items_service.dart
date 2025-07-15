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
    _instance = null;
    _isInitialized = false;
  }

  /// Busca items por stock
  static AsyncResult<List<Item>> getItemsByStock(
    String stockId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadItemsByStock(stockId, forceRefresh: forceRefresh);
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
  static AsyncResult<bool> deleteItem(String itemId, String stockId) async {
    await ensureInitialized();
    return _instance!.deleteItem(itemId, stockId);
  }

  /// Atualiza status de um item
  static AsyncResult<String> updateItemStatus(Item item) async {
    await ensureInitialized();
    return _instance!.updateItemStatus(item);
  }

  /// Atualiza código serial de um item
  static AsyncResult<Item> updateItemSerialCode(
    String itemId,
    int newSerialCode,
  ) async {
    await ensureInitialized();
    return _instance!.updateItemSerialCode(itemId, newSerialCode);
  }
}
