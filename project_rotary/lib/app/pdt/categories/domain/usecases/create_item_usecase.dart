import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:result_dart/result_dart.dart';

class CreateItemUseCase {
  final CategoryRepository _repository;

  CreateItemUseCase({required CategoryRepository repository})
    : _repository = repository;

  AsyncResult<Item> call({required CreateItemDTO createItemDTO}) async {
    try {
      // Validações de negócio
      if (!createItemDTO.isValid) {
        return Failure(Exception('Dados do item são inválidos'));
      }

      if (createItemDTO.categoryId <= 0) {
        return Failure(Exception('ID da categoria é obrigatório'));
      }

      if (createItemDTO.stockId.trim().isEmpty) {
        return Failure(Exception('ID do estoque é obrigatório'));
      }

      if (createItemDTO.imageUrl.trim().isEmpty) {
        return Failure(Exception('URL da imagem é obrigatória'));
      }

      return await _repository.createItem(createItemDTO: createItemDTO);
    } catch (e) {
      return Failure(Exception('Erro ao criar item: $e'));
    }
  }
}
