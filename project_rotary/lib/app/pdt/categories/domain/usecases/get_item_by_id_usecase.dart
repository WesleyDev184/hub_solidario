import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar um item por ID.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetItemByIdUseCase {
  final CategoryRepository _repository;

  GetItemByIdUseCase({required CategoryRepository repository})
    : _repository = repository;

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

      // Executa a operação no repositório
      final result = await _repository.getItemById(id: id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar item: ${e.toString()}'),
      );
    }
  }
}
