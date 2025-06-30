import 'package:flutter/foundation.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

class LoanController extends ChangeNotifier {
  final LoanRepository _loanRepository;

  LoanController(this._loanRepository);

  bool _isLoading = false;
  String? _error;
  Loan? _currentLoan;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Loan? get currentLoan => _currentLoan;

  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _loanRepository.updateLoan(
      id: id,
      updateLoanDTO: updateLoanDTO,
    );

    result.fold(
      (success) {
        _currentLoan = success;
      },
      (failure) {
        _error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<Loan> getLoanById({required String id}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _loanRepository.getLoanById(id: id);

    result.fold(
      (success) {
        _currentLoan = success;
      },
      (failure) {
        _error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<String> finalizeLoan({required String id}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _loanRepository.finalizeLoan(id: id);

    result.fold(
      (success) {
        // Empréstimo finalizado com sucesso
      },
      (failure) {
        _error = failure.toString().replaceFirst('Exception: ', '');
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }
}
