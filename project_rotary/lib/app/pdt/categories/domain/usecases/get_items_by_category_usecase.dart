import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar todos os itens de uma categoria específica.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetItemsByCategoryUseCase {
  final CategoryRepository _repository;

  GetItemsByCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de itens por categoria.
  ///
  /// [categoryId] - ID da categoria para buscar os itens
  ///
  /// Retorna [Success] com a lista de itens ou [Failure] em caso de erro.
  AsyncResult<List<Item>> call({required String categoryId}) async {
    try {
      // Validação básica
      if (categoryId.trim().isEmpty) {
        return Failure(Exception('ID da categoria não pode estar vazio'));
      }

      // Executa a operação no repositório
      final result = await _repository.getItemsByCategory(
        categoryId: categoryId,
      );

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar itens: ${e.toString()}'),
      );
    }
  }
}
