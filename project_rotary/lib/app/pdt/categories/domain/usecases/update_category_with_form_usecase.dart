import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_form_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:result_dart/result_dart.dart';

class UpdateCategoryWithFormUseCase {
  final CategoryRepository _categoryRepository;

  UpdateCategoryWithFormUseCase({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  AsyncResult<Category> call({
    required String id,
    required UpdateCategoryFormDTO updateCategoryFormDTO,
  }) async {
    // Validações locais
    if (id.trim().isEmpty) {
      return Failure(Exception('ID da categoria é obrigatório'));
    }

    if (updateCategoryFormDTO.isEmpty) {
      return Failure(Exception('Nenhum dado fornecido para atualização'));
    }

    // Chama o repositório
    return await _categoryRepository.updateCategoryWithForm(
      id: id,
      updateCategoryFormDTO: updateCategoryFormDTO,
    );
  }
}
