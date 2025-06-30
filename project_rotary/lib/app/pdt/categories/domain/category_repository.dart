import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_item_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/item.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:result_dart/result_dart.dart';

abstract class CategoryRepository {
  // Category operations
  AsyncResult<Category> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  });
  AsyncResult<List<Category>> getCategories();
  AsyncResult<Category> getCategoryById({required String id});
  AsyncResult<Category> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  });
  AsyncResult<String> deleteCategory({required String id});

  // Item operations
  AsyncResult<Item> createItem({required CreateItemDTO createItemDTO});
  AsyncResult<List<Item>> getItemsByCategory({required String categoryId});

  // User operations
  AsyncResult<List<User>> getUsers();
  AsyncResult<List<User>> getApplicants();
  AsyncResult<List<User>> getResponsibles();

  // Loan operations
  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO});
}
