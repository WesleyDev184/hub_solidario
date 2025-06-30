import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:result_dart/result_dart.dart';

class CreateCategoryUseCase {
  final CategoryRepository _repository;

  CreateCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<Category> call({
    required CreateCategoryDTO createCategoryDTO,
  }) async {
    try {
      // Validações de negócio
      if (createCategoryDTO.title.trim().length < 3) {
        return Failure(Exception('Título deve ter pelo menos 3 caracteres'));
      }

      if (createCategoryDTO.title.trim().length > 50) {
        return Failure(Exception('Título deve ter no máximo 50 caracteres'));
      }

      if (createCategoryDTO.orthopedicBankId.trim().isEmpty) {
        return Failure(Exception('Banco ortopédico é obrigatório'));
      }

      // Verificar se não contém palavras proibidas
      final forbiddenWords = ['teste', 'test', 'debug'];
      final titleLower = createCategoryDTO.title.toLowerCase();

      for (final word in forbiddenWords) {
        if (titleLower.contains(word)) {
          return Failure(Exception('Título não pode conter a palavra "$word"'));
        }
      }

      return await _repository.createCategory(
        createCategoryDTO: createCategoryDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao criar categoria: $e'));
    }
  }
}
