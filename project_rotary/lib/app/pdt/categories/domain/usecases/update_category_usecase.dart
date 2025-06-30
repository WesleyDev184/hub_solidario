import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:result_dart/result_dart.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _repository;

  UpdateCategoryUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<Category> call({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  }) async {
    try {
      // Validar se há mudanças
      if (_isEmpty(updateCategoryDTO)) {
        return Failure(Exception('Nenhuma alteração foi especificada'));
      }

      // Validações de negócio
      if (updateCategoryDTO.title != null) {
        if (updateCategoryDTO.title!.trim().length < 3) {
          return Failure(Exception('Título deve ter pelo menos 3 caracteres'));
        }

        if (updateCategoryDTO.title!.trim().length > 50) {
          return Failure(Exception('Título deve ter no máximo 50 caracteres'));
        }

        // Verificar palavras proibidas
        final forbiddenWords = ['teste', 'test', 'debug'];
        final titleLower = updateCategoryDTO.title!.toLowerCase();

        for (final word in forbiddenWords) {
          if (titleLower.contains(word)) {
            return Failure(
              Exception('Título não pode conter a palavra "$word"'),
            );
          }
        }
      }

      if (updateCategoryDTO.orthopedicBankId != null &&
          updateCategoryDTO.orthopedicBankId!.trim().isEmpty) {
        return Failure(Exception('Banco ortopédico é obrigatório'));
      }

      return await _repository.updateCategory(
        id: id,
        updateCategoryDTO: updateCategoryDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao atualizar categoria: $e'));
    }
  }

  bool _isEmpty(UpdateCategoryDTO dto) {
    return dto.isEmpty;
  }
}
