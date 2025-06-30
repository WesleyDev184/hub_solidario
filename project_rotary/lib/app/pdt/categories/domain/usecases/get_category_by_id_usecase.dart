import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar uma categoria por ID.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetCategoryByIdUseCase {
  final CategoryRepository _repository;

  GetCategoryByIdUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de uma categoria por ID.
  ///
  /// [id] - ID da categoria a ser buscada
  ///
  /// Retorna [Success] com a categoria encontrada ou [Failure] em caso de erro.
  AsyncResult<Category> call({required String id}) async {
    try {
      // Validação básica
      if (id.trim().isEmpty) {
        return Failure(Exception('ID da categoria não pode estar vazio'));
      }

      // Executa a operação no repositório
      final result = await _repository.getCategoryById(id: id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar categoria: ${e.toString()}'),
      );
    }
  }
}
