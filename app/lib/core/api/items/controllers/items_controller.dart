import 'package:app/core/api/items/models/items_models.dart';
import 'package:app/core/api/items/repositories/items_repository.dart';
import 'package:app/core/api/items/services/items_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de items
class ItemsController {
  final ItemsRepository _repository;
  final ItemsCacheService _cacheService;

  final bool _isLoading = false;
  String? _error;

  ItemsController(this._repository, this._cacheService);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

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

  /// Cria um novo item
  AsyncResult<String> createItem(CreateItemRequest request) async {
    try {
      final result = await _repository.createItem(request);

      return result.fold((item) async {
        await _cacheService.createItem(item);

        return Success(item.id);
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
        // Atualiza o cache
        _cacheService.updateCacheAfterModification(item);

        return Success(item);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um item
  AsyncResult<bool> deleteItem(String itemId, String stockId) async {
    try {
      final result = await _repository.deleteItem(itemId);

      return result.fold((success) {
        if (success) {
          // Remove do cache
          _cacheService.removeItemFromCache(itemId, stockId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza status de um item
  AsyncResult<String> updateItemStatus(Item item) async {
    try {
      await _cacheService.updateCacheAfterModification(item);
      return Success(item.id);
    } catch (e) {
      return Failure(Exception('Erro ao atualizar status do item: $e'));
    }
  }

  /// Atualiza código serial de um item
  AsyncResult<Item> updateItemSerialCode(
    String itemId,
    int newSerialCode,
  ) async {
    final request = UpdateItemRequest(serialCode: newSerialCode);
    return updateItem(itemId, request);
  }
}
