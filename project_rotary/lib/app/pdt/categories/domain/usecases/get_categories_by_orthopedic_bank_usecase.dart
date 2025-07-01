import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para buscar categorias por banco ortopédico através da rota de estoque.
/// Segue o padrão Clean Architecture implementado em outros use cases.
class GetCategoriesByOrthopedicBankUseCase {
  final CategoryRepository _repository;

  GetCategoriesByOrthopedicBankUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<List<Category>> call({required String orthopedicBankId}) async {
    try {
      return await _repository.getCategoriesByOrthopedicBank(
        orthopedicBankId: orthopedicBankId,
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar categorias do banco ortopédico: $e'),
      );
    }
  }
}
