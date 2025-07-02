import 'package:project_rotary/app/pdt/categories/data/item_service.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar um item por ID.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetItemByIdUseCase {
  final ItemService _itemService;

  GetItemByIdUseCase({ItemService? itemService})
    : _itemService = itemService ?? ItemService();

  /// Executa a busca de um item por ID.
  ///
  /// [id] - ID do item a ser buscado
  ///
  /// Retorna [Success] com o item encontrado ou [Failure] em caso de erro.
  AsyncResult<Item> call({required String id}) async {
    try {
      // Validação básica
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do item não pode estar vazio'));
      }

      // Executa a operação no service
      final result = await _itemService.getItemById(id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar item: ${e.toString()}'),
      );
    }
  }
}
