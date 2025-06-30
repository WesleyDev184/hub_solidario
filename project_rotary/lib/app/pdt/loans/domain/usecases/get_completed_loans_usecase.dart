import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para buscar empréstimos finalizados.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class GetCompletedLoansUseCase {
  final LoanRepository repository;

  const GetCompletedLoansUseCase({required this.repository});

  AsyncResult<List<Loan>> call() async {
    try {
      return await repository.getCompletedLoans();
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos finalizados: ${e.toString()}'),
      );
    }
  }
}
