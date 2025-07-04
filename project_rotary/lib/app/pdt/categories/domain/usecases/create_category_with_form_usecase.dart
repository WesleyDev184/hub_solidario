import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_form_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:result_dart/result_dart.dart';

class CreateCategoryWithFormUseCase {
  final CategoryRepository _categoryRepository;

  CreateCategoryWithFormUseCase({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  AsyncResult<Category> call({
    required CreateCategoryFormDTO createCategoryFormDTO,
  }) async {
    // Validações locais
    if (createCategoryFormDTO.title.trim().isEmpty) {
      return Failure(Exception('Título da categoria é obrigatório'));
    }

    if (createCategoryFormDTO.orthopedicBankId.trim().isEmpty) {
      return Failure(Exception('Banco ortopédico é obrigatório'));
    }

    if (!createCategoryFormDTO.hasImage) {
      return Failure(Exception('Imagem é obrigatória para criar a categoria'));
    }

    // Chama o repositório
    return await _categoryRepository.createCategoryWithForm(
      createCategoryFormDTO: createCategoryFormDTO,
    );
  }
}
