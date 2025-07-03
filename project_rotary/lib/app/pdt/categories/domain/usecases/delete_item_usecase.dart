import 'package:project_rotary/app/pdt/categories/data/item_service.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para deletar um item.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class DeleteItemUseCase {
  final ItemService _itemService;

  DeleteItemUseCase({ItemService? itemService})
    : _itemService = itemService ?? ItemService();

  /// Executa a exclusão de um item.
  ///
  /// [id] - ID do item a ser deletado
  ///
  /// Retorna [Success] com mensagem de sucesso ou [Failure] em caso de erro.
  AsyncResult<String> call({required String id}) async {
    try {
      // Validação básica
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do item não pode estar vazio'));
      }

      // Executa a operação no service
      final result = await _itemService.deleteItem(id);

      return result.fold(
        (success) => Success('Item deletado com sucesso'),
        (error) => Failure(error),
      );
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao deletar item: ${e.toString()}'),
      );
    }
  }
}
