import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:result_dart/result_dart.dart';

abstract class LoanRepository {
  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  });
  AsyncResult<Loan> getLoanById({required String id});
  AsyncResult<String> finalizeLoan({required String id});
}
