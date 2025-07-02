import 'package:project_rotary/app/pdt/categories/data/item_service.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';
import 'package:result_dart/result_dart.dart';

class CreateItemUseCase {
  final ItemService _itemService;

  CreateItemUseCase({ItemService? itemService})
    : _itemService = itemService ?? ItemService();

  AsyncResult<Item> call({required CreateItemDTO createItemDTO}) async {
    try {
      // Validações de negócio
      if (!createItemDTO.isValid) {
        return Failure(Exception('Dados do item são inválidos'));
      }

      if (createItemDTO.stockId.trim().isEmpty) {
        return Failure(Exception('ID do estoque é obrigatório'));
      }

      if (createItemDTO.serialCode <= 0) {
        return Failure(Exception('Código serial deve ser maior que zero'));
      }

      // imageUrl não é mais obrigatória

      return await _itemService.createItem(createItemDTO.toJson());
    } catch (e) {
      return Failure(Exception('Erro ao criar item: $e'));
    }
  }
}
