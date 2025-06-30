import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para atualizar um item existente.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class UpdateItemUseCase {
  final CategoryRepository _repository;

  UpdateItemUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a atualização de um item.
  ///
  /// [id] - ID do item a ser atualizado
  /// [updateItemDTO] - Dados para atualização do item
  ///
  /// Retorna [Success] com o item atualizado ou [Failure] em caso de erro.
  AsyncResult<Item> call({
    required String id,
    required UpdateItemDTO updateItemDTO,
  }) async {
    try {
      // Validações básicas
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do item não pode estar vazio'));
      }

      if (updateItemDTO.isEmpty) {
        return Failure(
          Exception('Pelo menos um campo deve ser fornecido para atualização'),
        );
      }

      if (!updateItemDTO.isValid) {
        return Failure(Exception('Dados de atualização inválidos'));
      }

      // Executa a operação no repositório
      final result = await _repository.updateItem(
        id: id,
        updateItemDTO: updateItemDTO,
      );

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao atualizar item: ${e.toString()}'),
      );
    }
  }
}
