import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de items na API
class ItemsRepository {
  final ApiClient _apiClient;

  const ItemsRepository(this._apiClient);

  /// Busca todos os items
  AsyncResult<List<Item>> getItems({ItemFilters? filters}) async {
    try {
      final queryParams = filters?.toQueryParams();
      final result = await _apiClient.get(
        '/items',
        useAuth: true,
        queryParams: queryParams,
      );

      return result.fold((data) {
        try {
          final response = ItemListResponse.fromJson(data);
          if (response.success) {
            return Success(response.data);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao buscar items'),
            );
          }
        } catch (e) {
          return Failure(Exception('Erro ao processar resposta dos items: $e'));
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um item por ID
  AsyncResult<Item> getItem(String itemId) async {
    try {
      final result = await _apiClient.get('/items/$itemId', useAuth: true);

      return result.fold((data) {
        try {
          final response = ItemResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Item não encontrado'),
            );
          }
        } catch (e) {
          return Failure(Exception('Erro ao processar resposta do item: $e'));
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca items por stock ID
  AsyncResult<List<Item>> getItemsByStock(String stockId) async {
    try {
      final result = await _apiClient.get(
        '/items/stock/$stockId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = ItemListResponse.fromJson(data);
          if (response.success) {
            return Success(response.data);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao buscar items do stock'),
            );
          }
        } catch (e) {
          return Failure(Exception('Erro ao processar resposta dos items: $e'));
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo item
  AsyncResult<String> createItem(CreateItemRequest request) async {
    try {
      final result = await _apiClient.post(
        '/items',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = CreateItemResponse.fromJson(data);
          if (response.success) {
            return Success(response.itemId ?? 'Item criado com sucesso');
          } else {
            return Failure(Exception(response.message ?? 'Erro ao criar item'));
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da criação: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um item existente
  AsyncResult<Item> updateItem(String itemId, UpdateItemRequest request) async {
    try {
      final result = await _apiClient.patch(
        '/items/$itemId',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = UpdateItemResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao atualizar item'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da atualização: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um item
  AsyncResult<bool> deleteItem(String itemId) async {
    try {
      final result = await _apiClient.delete('/items/$itemId', useAuth: true);

      return result.fold((data) {
        try {
          final response = DeleteItemResponse.fromJson(data);
          if (response.success) {
            return Success(true);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao deletar item'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca items disponíveis (status AVAILABLE)
  AsyncResult<List<Item>> getAvailableItems() async {
    final filters = ItemFilters(status: ItemStatus.available);
    return getItems(filters: filters);
  }

  /// Busca items em manutenção
  AsyncResult<List<Item>> getMaintenanceItems() async {
    final filters = ItemFilters(status: ItemStatus.maintenance);
    return getItems(filters: filters);
  }

  /// Busca items por status específico
  AsyncResult<List<Item>> getItemsByStatus(ItemStatus status) async {
    final filters = ItemFilters(status: status);
    return getItems(filters: filters);
  }

  /// Busca items por faixa de código serial
  AsyncResult<List<Item>> getItemsBySerialRange(
    int minCode,
    int maxCode,
  ) async {
    final filters = ItemFilters(minSeriaCode: minCode, maxSeriaCode: maxCode);
    return getItems(filters: filters);
  }

  /// Busca items criados em um período específico
  AsyncResult<List<Item>> getItemsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filters = ItemFilters(
      createdAfter: startDate,
      createdBefore: endDate,
    );
    return getItems(filters: filters);
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
}
