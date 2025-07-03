import 'package:flutter/foundation.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/api_config.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço para operações relacionadas aos itens através da API
class ItemService {
  final ApiClient _apiClient;

  ItemService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Busca todos os itens da API
  AsyncResult<List<Item>> getAllItems() async {
    try {
      debugPrint('ItemService: Buscando todos os itens');

      final result = await _apiClient.get(ApiEndpoints.items, useAuth: true);

      return result.fold(
        (data) {
          try {
            // Verifica se o retorno tem a estrutura esperada
            if (data['success'] == true && data['data'] is List) {
              final itemsData = data['data'] as List;
              debugPrint('ItemService: Raw items data: $itemsData');

              final items = <Item>[];
              for (int i = 0; i < itemsData.length; i++) {
                try {
                  final itemJson = itemsData[i] as Map<String, dynamic>;
                  debugPrint('ItemService: Processing item $i: $itemJson');
                  final item = Item.fromJson(itemJson);
                  items.add(item);
                } catch (e) {
                  debugPrint('ItemService: Erro ao processar item $i: $e');
                  debugPrint('ItemService: Item data: ${itemsData[i]}');
                  // Continue processando outros itens mesmo se um falhar
                }
              }

              debugPrint(
                'ItemService: ${items.length} itens carregados com sucesso',
              );
              return Success(items);
            } else {
              debugPrint('ItemService: Estrutura de resposta inválida: $data');
              return Failure(Exception('Estrutura de resposta inválida'));
            }
          } catch (e) {
            debugPrint('ItemService: Erro ao converter dados: $e');
            return Failure(Exception('Erro ao processar dados dos itens: $e'));
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca itens por categoria
  AsyncResult<List<Item>> getItemsByCategory(String categoryId) async {
    try {
      debugPrint('ItemService: Buscando itens da categoria $categoryId');

      final result = await _apiClient.get(
        ApiEndpoints.items,
        useAuth: true,
        queryParams: {'categoryId': categoryId},
      );

      return result.fold(
        (data) {
          try {
            // Verifica se o retorno tem a estrutura esperada
            if (data['success'] == true && data['data'] is List) {
              final itemsData = data['data'] as List;
              final items =
                  itemsData
                      .map(
                        (itemJson) =>
                            Item.fromJson(itemJson as Map<String, dynamic>),
                      )
                      .toList()
                      .where((item) => item.categoryId == categoryId)
                      .toList();

              debugPrint(
                'ItemService: ${items.length} itens da categoria $categoryId carregados',
              );
              return Success(items);
            } else {
              debugPrint('ItemService: Estrutura de resposta inválida: $data');
              return Failure(Exception('Estrutura de resposta inválida'));
            }
          } catch (e) {
            debugPrint('ItemService: Erro ao converter dados: $e');
            return Failure(Exception('Erro ao processar dados dos itens: $e'));
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca um item pelo ID
  AsyncResult<Item> getItemById(String itemId) async {
    try {
      debugPrint('ItemService: Buscando item $itemId');

      final result = await _apiClient.get(
        '${ApiEndpoints.items}/$itemId',
        useAuth: true,
      );

      return result.fold(
        (data) {
          try {
            // Verifica se o retorno tem a estrutura esperada
            if (data['success'] == true && data['data'] != null) {
              final item = Item.fromJson(data['data'] as Map<String, dynamic>);
              debugPrint('ItemService: Item $itemId carregado com sucesso');
              return Success(item);
            } else {
              debugPrint('ItemService: Item não encontrado: $data');
              return Failure(Exception('Item não encontrado'));
            }
          } catch (e) {
            debugPrint('ItemService: Erro ao converter dados: $e');
            return Failure(Exception('Erro ao processar dados do item: $e'));
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Cria um novo item
  AsyncResult<Item> createItem(Map<String, dynamic> itemData) async {
    try {
      debugPrint('ItemService: Criando novo item');

      final result = await _apiClient.post(
        ApiEndpoints.items,
        itemData,
        useAuth: true,
      );

      return result.fold(
        (data) {
          try {
            if (data['success'] == true) {
              // Se data é null, significa que o item foi criado mas não retornado
              // Neste caso, criamos um item mock ou fazemos uma nova busca
              if (data['data'] != null) {
                final item = Item.fromJson(
                  data['data'] as Map<String, dynamic>,
                );
                debugPrint('ItemService: Item criado com sucesso');
                return Success(item);
              } else {
                // API criou o item mas não retornou os dados
                // Criar um item temporário indicando sucesso
                debugPrint(
                  'ItemService: Item criado com sucesso (sem dados retornados)',
                );
                final tempItem = Item(
                  id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  serialCode: itemData['seriaCode'] as int,
                  stockId: itemData['stockId'] as String,
                  imageUrl: itemData['imageUrl'] as String? ?? '',
                  status: 'AVAILABLE',
                  categoryId:
                      itemData['stockId'] as String, // stockId é o categoryId
                  createdAt: DateTime.now(),
                );
                return Success(tempItem);
              }
            } else {
              debugPrint('ItemService: Erro ao criar item: $data');
              return Failure(
                Exception(data['message'] ?? 'Erro ao criar item'),
              );
            }
          } catch (e) {
            debugPrint('ItemService: Erro ao converter dados: $e');
            return Failure(Exception('Erro ao processar dados do item: $e'));
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um item existente
  AsyncResult<Item> updateItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      debugPrint('ItemService: Atualizando item $itemId');

      final result = await _apiClient.patch(
        '${ApiEndpoints.items}/$itemId',
        updateData,
        useAuth: true,
      );

      return result.fold(
        (data) {
          try {
            if (data['success'] == true && data['data'] != null) {
              final item = Item.fromJson(data['data'] as Map<String, dynamic>);
              debugPrint('ItemService: Item atualizado com sucesso');
              return Success(item);
            } else {
              debugPrint('ItemService: Erro ao atualizar item: $data');
              return Failure(
                Exception(data['message'] ?? 'Erro ao atualizar item'),
              );
            }
          } catch (e) {
            debugPrint('ItemService: Erro ao converter dados: $e');
            return Failure(Exception('Erro ao processar dados do item: $e'));
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um item
  AsyncResult<bool> deleteItem(String itemId) async {
    try {
      debugPrint('ItemService: Deletando item $itemId');

      final result = await _apiClient.delete(
        '${ApiEndpoints.items}/$itemId',
        useAuth: true,
      );

      return result.fold(
        (data) {
          if (data['success'] == true) {
            debugPrint('ItemService: Item deletado com sucesso');
            return Success(true);
          } else {
            debugPrint('ItemService: Erro ao deletar item: $data');
            return Failure(
              Exception(data['message'] ?? 'Erro ao deletar item'),
            );
          }
        },
        (error) {
          debugPrint('ItemService: Erro na requisição: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('ItemService: Erro inesperado: $e');
      return Failure(Exception('Erro inesperado: $e'));
    }
  }
}
