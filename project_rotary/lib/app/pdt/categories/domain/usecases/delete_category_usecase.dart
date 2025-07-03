import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:result_dart/result_dart.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<String> call({required String id}) async {
    try {
      if (id.trim().isEmpty) {
        return Failure(Exception('ID da categoria é obrigatório'));
      }

      return await _repository.deleteCategory(id: id);
    } catch (e) {
      return Failure(Exception('Erro ao excluir categoria: $e'));
    }
  }
}
