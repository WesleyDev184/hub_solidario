import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para atualizar empréstimos existentes.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class UpdateLoanUseCase {
  final LoanRepository repository;

  const UpdateLoanUseCase({required this.repository});

  AsyncResult<Loan> call({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    try {
      return await repository.updateLoan(id: id, updateLoanDTO: updateLoanDTO);
    } catch (e) {
      return Failure(
        Exception('Erro ao atualizar empréstimo: ${e.toString()}'),
      );
    }
  }
}
