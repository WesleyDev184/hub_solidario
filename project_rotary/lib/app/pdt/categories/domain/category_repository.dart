import 'package:project_rotary/app/pdt/categories/domain/dto/create_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_category_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/category.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/user.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Interface do repositório para gerenciar operações relacionadas a categorias,
/// empréstimos e usuários. Seguindo o padrão de Clean Architecture.
abstract class CategoryRepository {
  // Category operations
  AsyncResult<Category> createCategory({
    required CreateCategoryDTO createCategoryDTO,
  });
  AsyncResult<List<Category>> getCategories();
  AsyncResult<List<Category>> getCategoriesByOrthopedicBank({
    required String orthopedicBankId,
  });
  AsyncResult<Category> getCategoryById({required String id});
  AsyncResult<Category> updateCategory({
    required String id,
    required UpdateCategoryDTO updateCategoryDTO,
  });
  AsyncResult<String> deleteCategory({required String id});

  // User operations
  AsyncResult<List<User>> getUsers();
  AsyncResult<List<User>> getApplicants();
  AsyncResult<List<User>> getResponsibles();

  // Loan operations
  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO});
  AsyncResult<List<Loan>> getLoans();
  AsyncResult<Loan> getLoanById({required String id});
  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  });
  AsyncResult<String> deleteLoan({required String id});
  AsyncResult<List<Loan>> getLoansByApplicant({required String applicantId});
  AsyncResult<List<Loan>> getLoansByItem({required String itemId});
}
