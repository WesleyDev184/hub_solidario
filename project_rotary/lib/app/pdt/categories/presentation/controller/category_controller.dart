import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:result_dart/result_dart.dart';

class CategoryController extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  CategoryController(this._categoryRepository);

  bool isLoading = false;
  String? error;
  List<Category> categories = [];
  List<Item> items = [];
  List<User> users = [];
  List<User> applicants = [];
  List<User> responsibles = [];

  AsyncResult<Category> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.createCategory(
      createCategoryDTO: createCategoryDTO,
    );

    result.fold(
      (success) {
        // Adicionar a nova categoria à lista local
        categories.add(success);
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<List<Category>> getCategories() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.getCategories();

    result.fold(
      (success) {
        categories = success;
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<String> deleteCategory({required String id}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.deleteCategory(id: id);

    result.fold(
      (success) {
        // Remover a categoria da lista local
        categories.removeWhere((category) => category.id == id);
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<Category> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.updateCategory(
      id: id,
      updateCategoryDTO: updateCategoryDTO,
    );

    result.fold(
      (success) {
        // Atualizar categoria na lista local
        final index = categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          categories[index] = success;
        }
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<Item> createItem({required CreateItemDTO createItemDTO}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.createItem(
      createItemDTO: createItemDTO,
    );

    result.fold(
      (success) {
        items.add(success);
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<List<Item>> getItemsByCategory({
    required String categoryId,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.getItemsByCategory(
      categoryId: categoryId,
    );

    result.fold(
      (success) {
        items = success;
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<List<User>> getUsers() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.getUsers();

    result.fold(
      (success) {
        users = success;
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<List<User>> getApplicants() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.getApplicants();

    result.fold(
      (success) {
        applicants = success;
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<List<User>> getResponsibles() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.getResponsibles();

    result.fold(
      (success) {
        responsibles = success;
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _categoryRepository.createLoan(
      createLoanDTO: createLoanDTO,
    );

    result.fold(
      (success) {
        // Atualizar status do item emprestado
        final itemIndex = items.indexWhere(
          (item) => item.id == createLoanDTO.itemId,
        );
        if (itemIndex != -1) {
          // Criar novo item com status atualizado
          final updatedItem = Item(
            id: items[itemIndex].id,
            serialCode: items[itemIndex].serialCode,
            stockId: items[itemIndex].stockId,
            imageUrl: items[itemIndex].imageUrl,
            status: 'Emprestado',
            createdAt: items[itemIndex].createdAt,
          );
          items[itemIndex] = updatedItem;
        }
      },
      (failure) {
        error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    isLoading = false;
    notifyListeners();

    return result;
  }
}
