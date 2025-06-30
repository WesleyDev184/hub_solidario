import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para deletar um item.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class DeleteItemUseCase {
  final CategoryRepository _repository;

  DeleteItemUseCase({required CategoryRepository repository})
    : _repository = repository;

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

      // Executa a operação no repositório
      final result = await _repository.deleteItem(id: id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao deletar item: ${e.toString()}'),
      );
    }
  }
}
