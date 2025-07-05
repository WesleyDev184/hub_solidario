import 'package:project_rotary/app/pdt/categories/data/impl_category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_category_with_form_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_item_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_loan_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_item_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_loan_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_all_categories_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_all_loans_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_all_users_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_applicants_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_categories_by_orthopedic_bank_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_category_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_item_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_items_by_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_loan_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_loans_by_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_responsibles_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_category_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_category_with_form_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_item_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_loan_usecase.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/category_controller.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/item_controller.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/loan_controller.dart';

/// Fábrica de dependências para o módulo de categories.
/// Centraliza a criação e configuração de todas as dependências,
/// seguindo o padrão de Dependency Injection e Clean Architecture.
class CategoryDependencyFactory {
  static CategoryDependencyFactory? _instance;

  CategoryDependencyFactory._();

  static CategoryDependencyFactory get instance {
    _instance ??= CategoryDependencyFactory._();
    return _instance!;
  }

  // ========================================
  // REPOSITÓRIOS
  // ========================================

  CategoryRepository? _categoryRepository;

  CategoryRepository get categoryRepository {
    _categoryRepository ??= ImplCategoryRepository();
    return _categoryRepository!;
  }

  // ========================================
  // USE CASES - CATEGORY
  // ========================================

  CreateCategoryUseCase? _createCategoryUseCase;
  CreateCategoryWithFormUseCase? _createCategoryWithFormUseCase;
  GetAllCategoriesUseCase? _getAllCategoriesUseCase;
  GetCategoriesByOrthopedicBankUseCase? _getCategoriesByOrthopedicBankUseCase;
  GetCategoryByIdUseCase? _getCategoryByIdUseCase;
  UpdateCategoryUseCase? _updateCategoryUseCase;
  UpdateCategoryWithFormUseCase? _updateCategoryWithFormUseCase;
  DeleteCategoryUseCase? _deleteCategoryUseCase;

  CreateCategoryUseCase get createCategoryUseCase {
    _createCategoryUseCase ??= CreateCategoryUseCase(
      repository: categoryRepository,
    );
    return _createCategoryUseCase!;
  }

  CreateCategoryWithFormUseCase get createCategoryWithFormUseCase {
    _createCategoryWithFormUseCase ??= CreateCategoryWithFormUseCase(
      categoryRepository: categoryRepository,
    );
    return _createCategoryWithFormUseCase!;
  }

  GetAllCategoriesUseCase get getAllCategoriesUseCase {
    _getAllCategoriesUseCase ??= GetAllCategoriesUseCase(
      repository: categoryRepository,
    );
    return _getAllCategoriesUseCase!;
  }

  GetCategoriesByOrthopedicBankUseCase
  get getCategoriesByOrthopedicBankUseCase {
    _getCategoriesByOrthopedicBankUseCase ??=
        GetCategoriesByOrthopedicBankUseCase(repository: categoryRepository);
    return _getCategoriesByOrthopedicBankUseCase!;
  }

  GetCategoryByIdUseCase get getCategoryByIdUseCase {
    _getCategoryByIdUseCase ??= GetCategoryByIdUseCase(
      repository: categoryRepository,
    );
    return _getCategoryByIdUseCase!;
  }

  UpdateCategoryUseCase get updateCategoryUseCase {
    _updateCategoryUseCase ??= UpdateCategoryUseCase(
      repository: categoryRepository,
    );
    return _updateCategoryUseCase!;
  }

  UpdateCategoryWithFormUseCase get updateCategoryWithFormUseCase {
    _updateCategoryWithFormUseCase ??= UpdateCategoryWithFormUseCase(
      categoryRepository: categoryRepository,
    );
    return _updateCategoryWithFormUseCase!;
  }

  DeleteCategoryUseCase get deleteCategoryUseCase {
    _deleteCategoryUseCase ??= DeleteCategoryUseCase(
      repository: categoryRepository,
    );
    return _deleteCategoryUseCase!;
  }

  // ========================================
  // USE CASES - ITEM
  // ========================================

  CreateItemUseCase? _createItemUseCase;
  GetItemsByCategoryUseCase? _getItemsByCategoryUseCase;
  GetItemByIdUseCase? _getItemByIdUseCase;
  UpdateItemUseCase? _updateItemUseCase;
  DeleteItemUseCase? _deleteItemUseCase;

  CreateItemUseCase get createItemUseCase {
    _createItemUseCase ??= CreateItemUseCase();
    return _createItemUseCase!;
  }

  GetItemsByCategoryUseCase get getItemsByCategoryUseCase {
    _getItemsByCategoryUseCase ??= GetItemsByCategoryUseCase();
    return _getItemsByCategoryUseCase!;
  }

  GetItemByIdUseCase get getItemByIdUseCase {
    _getItemByIdUseCase ??= GetItemByIdUseCase();
    return _getItemByIdUseCase!;
  }

  UpdateItemUseCase get updateItemUseCase {
    _updateItemUseCase ??= UpdateItemUseCase();
    return _updateItemUseCase!;
  }

  DeleteItemUseCase get deleteItemUseCase {
    _deleteItemUseCase ??= DeleteItemUseCase();
    return _deleteItemUseCase!;
  }

  // ========================================
  // USE CASES - LOAN
  // ========================================

  CreateLoanUseCase? _createLoanUseCase;
  GetAllLoansUseCase? _getAllLoansUseCase;
  GetLoanByIdUseCase? _getLoanByIdUseCase;
  UpdateLoanUseCase? _updateLoanUseCase;
  DeleteLoanUseCase? _deleteLoanUseCase;
  GetLoansByApplicantUseCase? _getLoansByApplicantUseCase;

  CreateLoanUseCase get createLoanUseCase {
    _createLoanUseCase ??= CreateLoanUseCase(repository: categoryRepository);
    return _createLoanUseCase!;
  }

  GetAllLoansUseCase get getAllLoansUseCase {
    _getAllLoansUseCase ??= GetAllLoansUseCase(repository: categoryRepository);
    return _getAllLoansUseCase!;
  }

  GetLoanByIdUseCase get getLoanByIdUseCase {
    _getLoanByIdUseCase ??= GetLoanByIdUseCase(repository: categoryRepository);
    return _getLoanByIdUseCase!;
  }

  UpdateLoanUseCase get updateLoanUseCase {
    _updateLoanUseCase ??= UpdateLoanUseCase(repository: categoryRepository);
    return _updateLoanUseCase!;
  }

  DeleteLoanUseCase get deleteLoanUseCase {
    _deleteLoanUseCase ??= DeleteLoanUseCase(repository: categoryRepository);
    return _deleteLoanUseCase!;
  }

  GetLoansByApplicantUseCase get getLoansByApplicantUseCase {
    _getLoansByApplicantUseCase ??= GetLoansByApplicantUseCase(
      repository: categoryRepository,
    );
    return _getLoansByApplicantUseCase!;
  }

  // ========================================
  // USE CASES - USER
  // ========================================

  GetAllUsersUseCase? _getAllUsersUseCase;
  GetApplicantsUseCase? _getApplicantsUseCase;
  GetResponsiblesUseCase? _getResponsiblesUseCase;

  GetAllUsersUseCase get getAllUsersUseCase {
    _getAllUsersUseCase ??= GetAllUsersUseCase(repository: categoryRepository);
    return _getAllUsersUseCase!;
  }

  GetApplicantsUseCase get getApplicantsUseCase {
    _getApplicantsUseCase ??= GetApplicantsUseCase(
      repository: categoryRepository,
    );
    return _getApplicantsUseCase!;
  }

  GetResponsiblesUseCase get getResponsiblesUseCase {
    _getResponsiblesUseCase ??= GetResponsiblesUseCase(
      repository: categoryRepository,
    );
    return _getResponsiblesUseCase!;
  }

  // ========================================
  // CONTROLLERS
  // ========================================

  CategoryController? _categoryController;
  ItemController? _itemController;
  LoanController? _loanController;

  CategoryController get categoryController {
    _categoryController ??= CategoryController(
      createCategoryUseCase: createCategoryUseCase,
      createCategoryWithFormUseCase: createCategoryWithFormUseCase,
      getAllCategoriesUseCase: getAllCategoriesUseCase,
      getCategoriesByOrthopedicBankUseCase:
          getCategoriesByOrthopedicBankUseCase,
      getCategoryByIdUseCase: getCategoryByIdUseCase,
      updateCategoryUseCase: updateCategoryUseCase,
      updateCategoryWithFormUseCase: updateCategoryWithFormUseCase,
      deleteCategoryUseCase: deleteCategoryUseCase,
    );
    return _categoryController!;
  }

  ItemController get itemController {
    _itemController ??= ItemController(
      createItemUseCase: createItemUseCase,
      getItemsByCategoryUseCase: getItemsByCategoryUseCase,
      getItemByIdUseCase: getItemByIdUseCase,
      updateItemUseCase: updateItemUseCase,
      deleteItemUseCase: deleteItemUseCase,
    );
    return _itemController!;
  }

  LoanController get loanController {
    _loanController ??= LoanController(
      createLoanUseCase: createLoanUseCase,
      getAllLoansUseCase: getAllLoansUseCase,
      getLoanByIdUseCase: getLoanByIdUseCase,
      updateLoanUseCase: updateLoanUseCase,
      deleteLoanUseCase: deleteLoanUseCase,
      getLoansByApplicantUseCase: getLoansByApplicantUseCase,
      getApplicantsUseCase: getApplicantsUseCase,
      getResponsiblesUseCase: getResponsiblesUseCase,
    );
    return _loanController!;
  }

  // ========================================
  // RESET (para testes)
  // ========================================

  /// Reseta todas as instâncias. Útil para testes.
  void reset() {
    _instance = null;
    _categoryRepository = null;
    _createCategoryUseCase = null;
    _createCategoryWithFormUseCase = null;
    _getAllCategoriesUseCase = null;
    _getCategoryByIdUseCase = null;
    _updateCategoryUseCase = null;
    _deleteCategoryUseCase = null;
    _createItemUseCase = null;
    _getItemsByCategoryUseCase = null;
    _getItemByIdUseCase = null;
    _updateItemUseCase = null;
    _deleteItemUseCase = null;
    _createLoanUseCase = null;
    _getAllLoansUseCase = null;
    _getLoanByIdUseCase = null;
    _updateLoanUseCase = null;
    _deleteLoanUseCase = null;
    _getLoansByApplicantUseCase = null;
    _getAllUsersUseCase = null;
    _getApplicantsUseCase = null;
    _getResponsiblesUseCase = null;
    _categoryController = null;
    _itemController = null;
    _loanController = null;
  }
}
