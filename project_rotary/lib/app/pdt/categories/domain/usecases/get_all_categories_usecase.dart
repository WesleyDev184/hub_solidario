import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:result_dart/result_dart.dart';

class GetAllCategoriesUseCase {
  final CategoryRepository _repository;

  GetAllCategoriesUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<List<Category>> call() async {
    try {
      return await _repository.getCategories();
    } catch (e) {
      return Failure(Exception('Erro ao buscar categorias: $e'));
    }
  }
}
