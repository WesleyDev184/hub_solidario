import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_all_categories_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_category_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_category_usecase.dart';

/// Controller reativo para gerenciar o estado de categorias.
/// Implementa o padrão Clean Architecture usando Use Cases.
/// Baseado no mesmo padrão implementado no ApplicantController.
class CategoryController extends ChangeNotifier {
  final CreateCategoryUseCase _createCategoryUseCase;
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final GetCategoryByIdUseCase _getCategoryByIdUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoryController({
    required CreateCategoryUseCase createCategoryUseCase,
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required GetCategoryByIdUseCase getCategoryByIdUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
  }) : _createCategoryUseCase = createCategoryUseCase,
       _getAllCategoriesUseCase = getAllCategoriesUseCase,
       _getCategoryByIdUseCase = getCategoryByIdUseCase,
       _updateCategoryUseCase = updateCategoryUseCase,
       _deleteCategoryUseCase = deleteCategoryUseCase;

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _errorMessage;
  List<Category> _categories = [];
  Category? _selectedCategory;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Category> get categories => List.unmodifiable(_categories);
  Category? get selectedCategory => _selectedCategory;

  // ========================================
  // OPERAÇÕES CRUD
  // ========================================

  /// Cria uma nova categoria
  Future<void> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _createCategoryUseCase(
      createCategoryDTO: createCategoryDTO,
    );

    result.fold(
      (category) {
        _categories.add(category);
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao criar categoria: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca todas as categorias
  Future<void> getCategories() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllCategoriesUseCase();

    result.fold(
      (categoriesList) {
        _categories = categoriesList;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar categorias: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca uma categoria por ID
  Future<void> getCategoryById({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _getCategoryByIdUseCase(id: id);

    result.fold(
      (category) {
        _selectedCategory = category;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar categoria: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Atualiza uma categoria existente
  Future<void> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _updateCategoryUseCase(
      id: id,
      updateCategoryDTO: updateCategoryDTO,
    );

    result.fold(
      (updatedCategory) {
        final index = _categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }

        if (_selectedCategory?.id == id) {
          _selectedCategory = updatedCategory;
        }

        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao atualizar categoria: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Deleta uma categoria
  Future<void> deleteCategory({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteCategoryUseCase(id: id);

    result.fold(
      (message) {
        _categories.removeWhere((category) => category.id == id);

        if (_selectedCategory?.id == id) {
          _selectedCategory = null;
        }

        _setLoading(false);
      },
      (error) {
        _setError('Erro ao deletar categoria: ${_extractErrorMessage(error)}');
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

  /// Limpa a categoria selecionada
  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// Recarrega a lista de categorias
  Future<void> refresh() async {
    await getCategories();
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
