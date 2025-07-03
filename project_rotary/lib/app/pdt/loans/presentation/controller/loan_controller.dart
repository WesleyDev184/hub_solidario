import 'package:flutter/foundation.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/create_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/delete_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/finalize_loan_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_active_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_all_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_completed_loans_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_loan_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/get_loans_by_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/loans/domain/usecases/update_loan_usecase.dart';

/// Controller reativo para gerenciar o estado de empréstimos.
/// Implementa o padrão Clean Architecture usando Use Cases.
/// Baseado no mesmo padrão implementado no ApplicantController e CategoryController.
class LoanController extends ChangeNotifier {
  final CreateLoanUseCase _createLoanUseCase;
  final GetAllLoansUseCase _getAllLoansUseCase;
  final GetLoanByIdUseCase _getLoanByIdUseCase;
  final UpdateLoanUseCase _updateLoanUseCase;
  final DeleteLoanUseCase _deleteLoanUseCase;
  final FinalizeLoanUseCase _finalizeLoanUseCase;
  final GetLoansByApplicantUseCase _getLoansByApplicantUseCase;
  final GetActiveLoansUseCase _getActiveLoansUseCase;
  final GetCompletedLoansUseCase _getCompletedLoansUseCase;

  LoanController({
    required CreateLoanUseCase createLoanUseCase,
    required GetAllLoansUseCase getAllLoansUseCase,
    required GetLoanByIdUseCase getLoanByIdUseCase,
    required UpdateLoanUseCase updateLoanUseCase,
    required DeleteLoanUseCase deleteLoanUseCase,
    required FinalizeLoanUseCase finalizeLoanUseCase,
    required GetLoansByApplicantUseCase getLoansByApplicantUseCase,
    required GetActiveLoansUseCase getActiveLoansUseCase,
    required GetCompletedLoansUseCase getCompletedLoansUseCase,
  }) : _createLoanUseCase = createLoanUseCase,
       _getAllLoansUseCase = getAllLoansUseCase,
       _getLoanByIdUseCase = getLoanByIdUseCase,
       _updateLoanUseCase = updateLoanUseCase,
       _deleteLoanUseCase = deleteLoanUseCase,
       _finalizeLoanUseCase = finalizeLoanUseCase,
       _getLoansByApplicantUseCase = getLoansByApplicantUseCase,
       _getActiveLoansUseCase = getActiveLoansUseCase,
       _getCompletedLoansUseCase = getCompletedLoansUseCase;

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _errorMessage;
  List<Loan> _loans = [];
  Loan? _selectedLoan;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Loan> get loans => List.unmodifiable(_loans);
  Loan? get selectedLoan => _selectedLoan;

  // ========================================
  // OPERAÇÕES CRUD
  // ========================================

  /// Cria um novo empréstimo
  Future<void> createLoan({required CreateLoanDTO createLoanDTO}) async {
    _setLoading(true);
    _clearError();

    final result = await _createLoanUseCase(createLoanDTO: createLoanDTO);

    result.fold(
      (loan) {
        _loans.add(loan);
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao criar empréstimo: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca todos os empréstimos
  Future<void> getAllLoans() async {
    _setLoading(true);
    _clearError();

    final result = await _getAllLoansUseCase();

    result.fold(
      (loansList) {
        _loans = loansList;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar empréstimos: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Busca um empréstimo por ID
  Future<void> getLoanById({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _getLoanByIdUseCase(id: id);

    result.fold(
      (loan) {
        _selectedLoan = loan;
        _setLoading(false);
      },
      (error) {
        _setError('Erro ao buscar empréstimo: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Atualiza um empréstimo existente
  Future<void> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _updateLoanUseCase(
      id: id,
      updateLoanDTO: updateLoanDTO,
    );

    result.fold(
      (updatedLoan) {
        final index = _loans.indexWhere((loan) => loan.id == id);
        if (index != -1) {
          _loans[index] = updatedLoan;
        }

        if (_selectedLoan?.id == id) {
          _selectedLoan = updatedLoan;
        }

        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao atualizar empréstimo: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Deleta um empréstimo
  Future<void> deleteLoan({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteLoanUseCase(id: id);

    result.fold(
      (message) {
        _loans.removeWhere((loan) => loan.id == id);

        if (_selectedLoan?.id == id) {
          _selectedLoan = null;
        }

        _setLoading(false);
      },
      (error) {
        _setError('Erro ao deletar empréstimo: ${_extractErrorMessage(error)}');
        _setLoading(false);
      },
    );
  }

  /// Finaliza um empréstimo (marca como retornado)
  Future<void> finalizeLoan({required String id}) async {
    _setLoading(true);
    _clearError();

    final result = await _finalizeLoanUseCase(id: id);

    result.fold(
      (finalizedLoan) {
        final index = _loans.indexWhere((loan) => loan.id == id);
        if (index != -1) {
          _loans[index] = finalizedLoan;
        }

        if (_selectedLoan?.id == id) {
          _selectedLoan = finalizedLoan;
        }

        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao finalizar empréstimo: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Busca empréstimos por solicitante
  Future<void> getLoansByApplicant({required String applicantId}) async {
    _setLoading(true);
    _clearError();

    final result = await _getLoansByApplicantUseCase(applicantId: applicantId);

    result.fold(
      (loansList) {
        _loans = loansList;
        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao buscar empréstimos do solicitante: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Busca empréstimos ativos
  Future<void> getActiveLoans() async {
    _setLoading(true);
    _clearError();

    final result = await _getActiveLoansUseCase();

    result.fold(
      (loansList) {
        _loans = loansList;
        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao buscar empréstimos ativos: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Busca empréstimos finalizados
  Future<void> getCompletedLoans() async {
    _setLoading(true);
    _clearError();

    final result = await _getCompletedLoansUseCase();

    result.fold(
      (loansList) {
        _loans = loansList;
        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao buscar empréstimos finalizados: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _extractErrorMessage(Exception error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  /// Limpa o estado do controller
  void clearState() {
    _loans.clear();
    _selectedLoan = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Limpa apenas o erro
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
