import 'package:project_rotary/app/pdt/loans/data/impl_loan_repository.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/create_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/delete_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/finalize_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_active_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_all_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_completed_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_loan_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_loans_by_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/update_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/presentation/controller/loan_controller.dart';

/// Fábrica de dependências para o módulo de loans.
/// Centraliza a criação e configuração de todas as dependências,
/// seguindo o padrão de Dependency Injection e Clean Architecture.
/// Baseado no mesmo padrão implementado em applicants e categories.
class LoanDependencyFactory {
  static LoanDependencyFactory? _instance;

  LoanDependencyFactory._();

  static LoanDependencyFactory get instance {
    _instance ??= LoanDependencyFactory._();
    return _instance!;
  }

  // ========================================
  // REPOSITÓRIOS
  // ========================================

  LoanRepository? _loanRepository;

  LoanRepository get loanRepository {
    _loanRepository ??= ImplLoanRepository();
    return _loanRepository!;
  }

  // ========================================
  // USE CASES
  // ========================================

  CreateLoanUseCase? _createLoanUseCase;
  GetAllLoansUseCase? _getAllLoansUseCase;
  GetLoanByIdUseCase? _getLoanByIdUseCase;
  UpdateLoanUseCase? _updateLoanUseCase;
  DeleteLoanUseCase? _deleteLoanUseCase;
  FinalizeLoanUseCase? _finalizeLoanUseCase;
  GetLoansByApplicantUseCase? _getLoansByApplicantUseCase;
  GetActiveLoansUseCase? _getActiveLoansUseCase;
  GetCompletedLoansUseCase? _getCompletedLoansUseCase;

  CreateLoanUseCase get createLoanUseCase {
    _createLoanUseCase ??= CreateLoanUseCase(repository: loanRepository);
    return _createLoanUseCase!;
  }

  GetAllLoansUseCase get getAllLoansUseCase {
    _getAllLoansUseCase ??= GetAllLoansUseCase(repository: loanRepository);
    return _getAllLoansUseCase!;
  }

  GetLoanByIdUseCase get getLoanByIdUseCase {
    _getLoanByIdUseCase ??= GetLoanByIdUseCase(repository: loanRepository);
    return _getLoanByIdUseCase!;
  }

  UpdateLoanUseCase get updateLoanUseCase {
    _updateLoanUseCase ??= UpdateLoanUseCase(repository: loanRepository);
    return _updateLoanUseCase!;
  }

  DeleteLoanUseCase get deleteLoanUseCase {
    _deleteLoanUseCase ??= DeleteLoanUseCase(repository: loanRepository);
    return _deleteLoanUseCase!;
  }

  FinalizeLoanUseCase get finalizeLoanUseCase {
    _finalizeLoanUseCase ??= FinalizeLoanUseCase(repository: loanRepository);
    return _finalizeLoanUseCase!;
  }

  GetLoansByApplicantUseCase get getLoansByApplicantUseCase {
    _getLoansByApplicantUseCase ??= GetLoansByApplicantUseCase(
      repository: loanRepository,
    );
    return _getLoansByApplicantUseCase!;
  }

  GetActiveLoansUseCase get getActiveLoansUseCase {
    _getActiveLoansUseCase ??= GetActiveLoansUseCase(
      repository: loanRepository,
    );
    return _getActiveLoansUseCase!;
  }

  GetCompletedLoansUseCase get getCompletedLoansUseCase {
    _getCompletedLoansUseCase ??= GetCompletedLoansUseCase(
      repository: loanRepository,
    );
    return _getCompletedLoansUseCase!;
  }

  // ========================================
  // CONTROLLERS
  // ========================================

  LoanController? _loanController;

  LoanController get loanController {
    _loanController ??= LoanController(
      createLoanUseCase: createLoanUseCase,
      getAllLoansUseCase: getAllLoansUseCase,
      getLoanByIdUseCase: getLoanByIdUseCase,
      updateLoanUseCase: updateLoanUseCase,
      deleteLoanUseCase: deleteLoanUseCase,
      finalizeLoanUseCase: finalizeLoanUseCase,
      getLoansByApplicantUseCase: getLoansByApplicantUseCase,
      getActiveLoansUseCase: getActiveLoansUseCase,
      getCompletedLoansUseCase: getCompletedLoansUseCase,
    );
    return _loanController!;
  }

  // ========================================
  // RESET (para testes)
  // ========================================

  /// Reseta todas as instâncias. Útil para testes.
  void reset() {
    _instance = null;
    _loanRepository = null;
    _createLoanUseCase = null;
    _getAllLoansUseCase = null;
    _getLoanByIdUseCase = null;
    _updateLoanUseCase = null;
    _deleteLoanUseCase = null;
    _finalizeLoanUseCase = null;
    _getLoansByApplicantUseCase = null;
    _getActiveLoansUseCase = null;
    _getCompletedLoansUseCase = null;
    _loanController = null;
  }
}
