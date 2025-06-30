import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/create_loan_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/delete_loan_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_all_loans_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_applicants_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_loan_by_id_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_loans_by_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/get_responsibles_usecase.dart';
import 'package:project_rotary/app/pdt/categories/domain/usecases/update_loan_usecase.dart';

/// Controller reativo para gerenciar o estado de empréstimos.
/// Implementa o padrão Clean Architecture usando Use Cases.
/// Baseado no mesmo padrão implementado no ApplicantController.
class LoanController extends ChangeNotifier {
  final CreateLoanUseCase _createLoanUseCase;
  final GetAllLoansUseCase _getAllLoansUseCase;
  final GetLoanByIdUseCase _getLoanByIdUseCase;
  final UpdateLoanUseCase _updateLoanUseCase;
  final DeleteLoanUseCase _deleteLoanUseCase;
  final GetLoansByApplicantUseCase _getLoansByApplicantUseCase;
  final GetApplicantsUseCase _getApplicantsUseCase;
  final GetResponsiblesUseCase _getResponsiblesUseCase;

  LoanController({
    required CreateLoanUseCase createLoanUseCase,
    required GetAllLoansUseCase getAllLoansUseCase,
    required GetLoanByIdUseCase getLoanByIdUseCase,
    required UpdateLoanUseCase updateLoanUseCase,
    required DeleteLoanUseCase deleteLoanUseCase,
    required GetLoansByApplicantUseCase getLoansByApplicantUseCase,
    required GetApplicantsUseCase getApplicantsUseCase,
    required GetResponsiblesUseCase getResponsiblesUseCase,
  }) : _createLoanUseCase = createLoanUseCase,
       _getAllLoansUseCase = getAllLoansUseCase,
       _getLoanByIdUseCase = getLoanByIdUseCase,
       _updateLoanUseCase = updateLoanUseCase,
       _deleteLoanUseCase = deleteLoanUseCase,
       _getLoansByApplicantUseCase = getLoansByApplicantUseCase,
       _getApplicantsUseCase = getApplicantsUseCase,
       _getResponsiblesUseCase = getResponsiblesUseCase;

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _errorMessage;
  List<Loan> _loans = [];
  Loan? _selectedLoan;
  List<User> _applicants = [];
  List<User> _responsibles = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Loan> get loans => List.unmodifiable(_loans);
  Loan? get selectedLoan => _selectedLoan;
  List<User> get applicants => List.unmodifiable(_applicants);
  List<User> get responsibles => List.unmodifiable(_responsibles);

  // ========================================
  // OPERAÇÕES CRUD - LOAN
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
  Future<void> getLoans() async {
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

  // ========================================
  // OPERAÇÕES - USERS
  // ========================================

  /// Busca usuários que podem ser solicitantes
  Future<void> getApplicants() async {
    _setLoading(true);
    _clearError();

    final result = await _getApplicantsUseCase();

    result.fold(
      (applicantsList) {
        _applicants = applicantsList;
        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao buscar solicitantes: ${_extractErrorMessage(error)}',
        );
        _setLoading(false);
      },
    );
  }

  /// Busca usuários que podem ser responsáveis
  Future<void> getResponsibles() async {
    _setLoading(true);
    _clearError();

    final result = await _getResponsiblesUseCase();

    result.fold(
      (responsiblesList) {
        _responsibles = responsiblesList;
        _setLoading(false);
      },
      (error) {
        _setError(
          'Erro ao buscar responsáveis: ${_extractErrorMessage(error)}',
        );
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

  /// Limpa o empréstimo selecionado
  void clearSelectedLoan() {
    _selectedLoan = null;
    notifyListeners();
  }

  /// Recarrega a lista de empréstimos
  Future<void> refresh() async {
    await getLoans();
  }

  /// Carrega dados iniciais necessários para criar empréstimos
  Future<void> loadInitialData() async {
    await Future.wait([getApplicants(), getResponsibles()]);
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
