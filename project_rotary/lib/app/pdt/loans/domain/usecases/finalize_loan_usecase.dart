import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para finalizar empréstimos (marcar como retornado).
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class FinalizeLoanUseCase {
  final LoanRepository repository;

  const FinalizeLoanUseCase({required this.repository});

  AsyncResult<Loan> call({required String id}) async {
    try {
      return await repository.finalizeLoan(id: id);
    } catch (e) {
      return Failure(
        Exception('Erro ao finalizar empréstimo: ${e.toString()}'),
      );
    }
  }
}
