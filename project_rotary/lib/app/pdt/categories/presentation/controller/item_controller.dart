import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_item_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_item_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_item_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_items_by_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_item_usecase.dart';

/// Controller reativo para gerenciar o estado de itens.
/// Implementa o padrão Clean Architecture usando Use Cases.
/// Baseado no mesmo padrão implementado no ApplicantController.
class ItemController extends ChangeNotifier {
  final CreateItemUseCase _createItemUseCase;
  final GetItemsByCategoryUseCase _getItemsByCategoryUseCase;
  final GetItemByIdUseCase _getItemByIdUseCase;
  final UpdateItemUseCase _updateItemUseCase;
  final DeleteItemUseCase _deleteItemUseCase;

  ItemController({
    required CreateItemUseCase createItemUseCase,
    required GetItemsByCategoryUseCase getItemsByCategoryUseCase,
    required GetItemByIdUseCase getItemByIdUseCase,
    required UpdateItemUseCase updateItemUseCase,
    required DeleteItemUseCase deleteItemUseCase,
  }) : _createItemUseCase = createItemUseCase,
       _getItemsByCategoryUseCase = getItemsByCategoryUseCase,
       _getItemByIdUseCase = getItemByIdUseCase,
       _updateItemUseCase = updateItemUseCase,
       _deleteItemUseCase = deleteItemUseCase;

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _errorMessage;
  List<Item> _items = [];
  Item? _selectedItem;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Item> get items => List.unmodifiable(_items);
  Item? get selectedItem => _selectedItem;

  // ========================================
  // OPERAÇÕES CRUD
  // ========================================

  /// Cria um novo item
  Future<void> createItem({required CreateItemDTO createItemDTO}) async {
    _setLoading(true);
    _clearError();

    final result = await _createItemUseCase(createItemDTO: createItemDTO);

    result.fold(
      (item) {
        _items.add(item);
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao criar item: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca itens por categoria
  Future<void> getItemsByCategory({required String categoryId}) async {
    _setLoading(true);
    _clearError();

    final result = await _getItemsByCategoryUseCase(categoryId: categoryId);

    result.fold(
      (itemsList) {
        _items = itemsList;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar itens: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca um item por ID
  Future<void> getItemById({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _getItemByIdUseCase(id: id);

    result.fold(
      (item) {
        _selectedItem = item;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar item: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Atualiza um item existente
  Future<void> updateItem({
    required String id,
    required UpdateItemDTO updateItemDTO,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _updateItemUseCase(
      id: id,
      updateItemDTO: updateItemDTO,
    );

    result.fold(
      (updatedItem) {
        final index = _items.indexWhere((item) => item.id == id);
        if (index != -1) {
          _items[index] = updatedItem;
        }

        if (_selectedItem?.id == id) {
          _selectedItem = updatedItem;
        }

        _setLoading(false);
      },
      (error) {
        _setError('Erro ao atualizar item: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Deleta um item
  Future<void> deleteItem({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteItemUseCase(id: id);

    result.fold(
      (message) {
        _items.removeWhere((item) => item.id == id);

        if (_selectedItem?.id == id) {
          _selectedItem = null;
        }

        _setLoading(false);
      },
      (error) {
        _setError('Erro ao deletar item: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /// Limpa o erro atual
  void clearError() {
    _clearError();
  }

  /// Limpa o item selecionado
  void clearSelectedItem() {
    _selectedItem = null;
    notifyListeners();
  }

  /// Recarrega a lista de itens por categoria
  Future<void> refresh({required String categoryId}) async {
    await getItemsByCategory(categoryId: categoryId);
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _extractErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
