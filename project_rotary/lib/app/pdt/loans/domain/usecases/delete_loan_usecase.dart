import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para deletar empréstimos.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class DeleteLoanUseCase {
  final LoanRepository repository;

  const DeleteLoanUseCase({required this.repository});

  AsyncResult<String> call({required String id}) async {
    try {
      return await repository.deleteLoan(id: id);
    } catch (e) {
      return Failure(Exception('Erro ao deletar empréstimo: ${e.toString()}'));
    }
  }
}
