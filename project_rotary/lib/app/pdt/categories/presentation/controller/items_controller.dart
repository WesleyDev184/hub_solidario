import 'package:flutter/foundation.dart';
import 'package:project_rotary/app/pdt/categories/data/item_service.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/item.dart';

/// Controller para gerenciar o estado dos itens
class ItemsController extends ChangeNotifier {
  final ItemService _itemService;

  ItemsController({ItemService? itemService})
    : _itemService = itemService ?? ItemService();

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _errorMessage;
  List<Item> _items = [];
  Item? _selectedItem;

  // ========================================
  // GETTERS
  // ========================================

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Item> get items => List.unmodifiable(_items);
  Item? get selectedItem => _selectedItem;

  // Contadores por status
  int get totalItems => _items.length;
  int get availableItems =>
      _items
          .where(
            (item) =>
                item.status.toUpperCase() == 'AVAILABLE' ||
                item.status == 'Available' ||
                item.status == 'Disponível',
          )
          .length;
  int get borrowedItems =>
      _items
          .where(
            (item) =>
                item.status.toUpperCase() == 'BORROWED' ||
                item.status == 'Borrowed' ||
                item.status == 'Emprestado',
          )
          .length;
  int get maintenanceItems =>
      _items
          .where(
            (item) =>
                item.status.toUpperCase() == 'MAINTENANCE' ||
                item.status == 'Maintenance' ||
                item.status == 'Em manutenção',
          )
          .length;

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // ========================================
  // OPERAÇÕES PÚBLICAS
  // ========================================

  /// Carrega todos os itens
  Future<void> loadAllItems() async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.getAllItems();

    result.fold(
      (items) {
        _items = items;
        _setLoading(false);
        debugPrint('ItemsController: ${items.length} itens carregados');
      },
      (error) {
        _setError('Erro ao carregar itens: ${error.toString()}');
        _setLoading(false);
        debugPrint('ItemsController: Erro ao carregar itens: $error');
      },
    );
  }

  /// Carrega itens por categoria
  Future<void> loadItemsByCategory(String categoryId) async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.getItemsByCategory(categoryId);

    result.fold(
      (items) {
        _items = items;
        _setLoading(false);
        debugPrint(
          'ItemsController: ${items.length} itens da categoria carregados',
        );
      },
      (error) {
        _setError('Erro ao carregar itens da categoria: ${error.toString()}');
        _setLoading(false);
        debugPrint(
          'ItemsController: Erro ao carregar itens da categoria: $error',
        );
      },
    );
  }

  /// Carrega um item específico pelo ID
  Future<void> loadItemById(String itemId) async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.getItemById(itemId);

    result.fold(
      (item) {
        _selectedItem = item;
        // Atualiza o item na lista se já existir
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = item;
        }
        _setLoading(false);
        debugPrint('ItemsController: Item ${item.id} carregado');
      },
      (error) {
        _setError('Erro ao carregar item: ${error.toString()}');
        _setLoading(false);
        debugPrint('ItemsController: Erro ao carregar item: $error');
      },
    );
  }

  /// Cria um novo item
  Future<bool> createItem(Map<String, dynamic> itemData) async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.createItem(itemData);

    return result.fold(
      (item) {
        _items.add(item);
        _setLoading(false);
        debugPrint('ItemsController: Item criado com sucesso');
        return true;
      },
      (error) {
        _setError('Erro ao criar item: ${error.toString()}');
        _setLoading(false);
        debugPrint('ItemsController: Erro ao criar item: $error');
        return false;
      },
    );
  }

  /// Atualiza um item existente
  Future<bool> updateItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.updateItem(itemId, updateData);

    return result.fold(
      (updatedItem) {
        final index = _items.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _items[index] = updatedItem;
        }
        if (_selectedItem?.id == itemId) {
          _selectedItem = updatedItem;
        }
        _setLoading(false);
        debugPrint('ItemsController: Item atualizado com sucesso');
        return true;
      },
      (error) {
        _setError('Erro ao atualizar item: ${error.toString()}');
        _setLoading(false);
        debugPrint('ItemsController: Erro ao atualizar item: $error');
        return false;
      },
    );
  }

  /// Deleta um item
  Future<bool> deleteItem(String itemId) async {
    _setLoading(true);
    _clearError();

    final result = await _itemService.deleteItem(itemId);

    return result.fold(
      (success) {
        if (success) {
          _items.removeWhere((item) => item.id == itemId);
          if (_selectedItem?.id == itemId) {
            _selectedItem = null;
          }
        }
        _setLoading(false);
        debugPrint('ItemsController: Item deletado com sucesso');
        return success;
      },
      (error) {
        _setError('Erro ao deletar item: ${error.toString()}');
        _setLoading(false);
        debugPrint('ItemsController: Erro ao deletar item: $error');
        return false;
      },
    );
  }

  /// Filtra itens por status
  List<Item> getItemsByStatus(String status) {
    return _items.where((item) => item.status == status).toList();
  }

  /// Limpa o item selecionado
  void clearSelectedItem() {
    _selectedItem = null;
    notifyListeners();
  }

  /// Recarrega os itens (útil para pull-to-refresh)
  Future<void> refresh() async {
    // Se não temos itens carregados, carrega todos
    // Caso contrário, mantém o contexto atual (por exemplo, se estamos numa categoria específica)
    if (_items.isEmpty) {
      await loadAllItems();
    } else {
      // Pode implementar lógica mais específica aqui se necessário
      await loadAllItems();
    }
  }

  /// Limpa todos os dados
  void clear() {
    _items.clear();
    _selectedItem = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
