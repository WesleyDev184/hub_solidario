import 'package:project_rotary/core/api/items/models/items_models.dart';
import 'package:project_rotary/core/api/items/repositories/items_repository.dart';
import 'package:project_rotary/core/api/items/services/items_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de items
class ItemsController {
  final ItemsRepository _repository;
  final ItemsCacheService _cacheService;

  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  ItemsController(this._repository, this._cacheService);

  /// Lista de items atual
  List<Item> get items => List.unmodifiable(_items);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Verifica se tem dados carregados
  bool get hasData => _items.isNotEmpty;

  /// Carrega todos os items
  AsyncResult<List<Item>> loadItems({
    bool forceRefresh = false,
    ItemFilters? filters,
  }) async {
    if (_isLoading) {
      return Success(_items);
    }

    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro, se não for refresh forçado e não tiver filtros
      if (!forceRefresh && filters == null) {
        final cachedItems = await _cacheService.getCachedItems();
        if (cachedItems != null) {
          _items = cachedItems;
          _isLoading = false;
          return Success(_items);
        }
      }

      // Busca da API
      final result = await _repository.getItems(filters: filters);

      return result.fold(
        (items) {
          _items = items;
          _isLoading = false;

          // Salva no cache apenas se não tiver filtros
          if (filters == null) {
            _cacheService.cacheItems(items);
          }

          return Success(items);
        },
        (error) {
          _error = error.toString();
          _isLoading = false;

          // Se falhar e não tiver cache, usa lista vazia
          if (_items.isEmpty) {
            return Failure(error);
          }

          // Se falhar mas tiver cache, retorna o cache
          return Success(_items);
        },
      );
    } catch (e) {
      _error = 'Erro inesperado: $e';
      _isLoading = false;
      return Failure(Exception(_error!));
    }
  }

  /// Busca items por stock
  AsyncResult<List<Item>> loadItemsByStock(
    String stockId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedItems = await _cacheService.getCachedItemsByStock(stockId);
        if (cachedItems != null) {
          return Success(cachedItems);
        }
      }

      // Busca da API
      final result = await _repository.getItemsByStock(stockId);

      return result.fold((items) {
        // Salva no cache
        _cacheService.cacheItemsByStock(stockId, items);

        return Success(items);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca um item por ID
  AsyncResult<Item> getItem(String itemId, {bool forceRefresh = false}) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedItem = await _cacheService.getCachedItem(itemId);
        if (cachedItem != null) {
          return Success(cachedItem);
        }
      }

      // Busca da API
      final result = await _repository.getItem(itemId);

      return result.fold((item) {
        // Salva no cache
        _cacheService.cacheItem(item);

        return Success(item);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Cria um novo item
  AsyncResult<String> createItem(CreateItemRequest request) async {
    try {
      final result = await _repository.createItem(request);

      return result.fold((itemId) {
        // Limpa o cache para forçar recarregamento
        _cacheService.clearCache();

        // Se o item foi criado com sucesso, recarrega a lista
        loadItems(forceRefresh: true);

        return Success(itemId);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um item existente
  AsyncResult<Item> updateItem(String itemId, UpdateItemRequest request) async {
    try {
      final result = await _repository.updateItem(itemId, request);

      return result.fold((item) {
        // Atualiza o item na lista local
        final index = _items.indexWhere((i) => i.id == itemId);
        if (index != -1) {
          _items[index] = item;
        }

        // Atualiza o cache
        _cacheService.updateCacheAfterModification(item);

        return Success(item);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um item
  AsyncResult<bool> deleteItem(String itemId) async {
    try {
      final result = await _repository.deleteItem(itemId);

      return result.fold((success) {
        if (success) {
          // Remove o item da lista local
          _items.removeWhere((item) => item.id == itemId);

          // Remove do cache
          _cacheService.removeItemFromCache(itemId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca items disponíveis
  AsyncResult<List<Item>> getAvailableItems({bool forceRefresh = false}) async {
    if (!forceRefresh && _items.isNotEmpty) {
      final availableItems =
          _items.where((item) => item.isAvailableForLoan).toList();
      return Success(availableItems);
    }

    return _repository.getAvailableItems();
  }

  /// Busca items em manutenção
  AsyncResult<List<Item>> getMaintenanceItems({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _items.isNotEmpty) {
      final maintenanceItems =
          _items.where((item) => item.needsMaintenance).toList();
      return Success(maintenanceItems);
    }

    return _repository.getMaintenanceItems();
  }

  /// Busca items por status (busca local)
  List<Item> getItemsByStatus(ItemStatus status) {
    return _items.where((item) => item.status == status).toList();
  }

  /// Busca items por stock (busca local)
  List<Item> getItemsByStock(String stockId) {
    return _items.where((item) => item.stockId == stockId).toList();
  }

  /// Busca items por código serial (busca local)
  List<Item> searchItemsBySerialCode(int serialCode) {
    return _items.where((item) => item.seriaCode == serialCode).toList();
  }

  /// Busca items por faixa de código serial (busca local)
  List<Item> getItemsBySerialRange(int minCode, int maxCode) {
    return _items
        .where((item) => item.seriaCode >= minCode && item.seriaCode <= maxCode)
        .toList();
  }

  /// Atualiza status de um item
  AsyncResult<Item> updateItemStatus(
    String itemId,
    ItemStatus newStatus,
  ) async {
    final request = UpdateItemRequest(status: newStatus);
    return updateItem(itemId, request);
  }

  /// Atualiza código serial de um item
  AsyncResult<Item> updateItemSerialCode(
    String itemId,
    int newSerialCode,
  ) async {
    final request = UpdateItemRequest(seriaCode: newSerialCode);
    return updateItem(itemId, request);
  }

  /// Obtém estatísticas dos items
  Map<String, int> getItemsStatistics() {
    int totalItems = _items.length;
    int availableItems =
        _items.where((i) => i.status == ItemStatus.available).length;
    int maintenanceItems =
        _items.where((i) => i.status == ItemStatus.maintenance).length;
    int unavailableItems =
        _items.where((i) => i.status == ItemStatus.unavailable).length;
    int lostItems = _items.where((i) => i.status == ItemStatus.lost).length;
    int donatedItems =
        _items.where((i) => i.status == ItemStatus.donated).length;

    // Agrupa por stock
    Map<String, int> itemsByStock = {};
    for (final item in _items) {
      itemsByStock[item.stockId] = (itemsByStock[item.stockId] ?? 0) + 1;
    }

    return {
      'totalItems': totalItems,
      'availableItems': availableItems,
      'maintenanceItems': maintenanceItems,
      'unavailableItems': unavailableItems,
      'lostItems': lostItems,
      'donatedItems': donatedItems,
      'uniqueStocks': itemsByStock.length,
    };
  }

  /// Obtém estatísticas por stock
  Map<String, Map<String, int>> getStatisticsByStock() {
    Map<String, Map<String, int>> stockStats = {};

    for (final item in _items) {
      if (!stockStats.containsKey(item.stockId)) {
        stockStats[item.stockId] = {
          'total': 0,
          'available': 0,
          'maintenance': 0,
          'unavailable': 0,
          'lost': 0,
          'donated': 0,
        };
      }

      stockStats[item.stockId]!['total'] =
          stockStats[item.stockId]!['total']! + 1;
      stockStats[item.stockId]![item.status.value.toLowerCase()] =
          (stockStats[item.stockId]![item.status.value.toLowerCase()] ?? 0) + 1;
    }

    return stockStats;
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _items.clear();
    _error = null;
    _isLoading = false;
    await _cacheService.clearCache();
  }

  /// Força atualização dos dados
  AsyncResult<List<Item>> refreshItems() async {
    return loadItems(forceRefresh: true);
  }

  /// Verifica se um item específico está disponível
  bool isItemAvailable(String itemId) {
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      return item.isAvailableForLoan;
    } catch (e) {
      return false;
    }
  }

  /// Obtém o status de um item
  ItemStatus? getItemStatus(String itemId) {
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      return item.status;
    } catch (e) {
      return null;
    }
  }

  /// Obtém o código serial de um item
  int? getItemSerialCode(String itemId) {
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      return item.seriaCode;
    } catch (e) {
      return null;
    }
  }
}
