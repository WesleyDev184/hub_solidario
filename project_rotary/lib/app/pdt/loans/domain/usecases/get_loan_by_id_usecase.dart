import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para buscar um empréstimo por ID.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class GetLoanByIdUseCase {
  final LoanRepository repository;

  const GetLoanByIdUseCase({required this.repository});

  AsyncResult<Loan> call({required String id}) async {
    try {
      return await repository.getLoanById(id: id);
    } catch (e) {
      return Failure(Exception('Erro ao buscar empréstimo: ${e.toString()}'));
    }
  }
}
