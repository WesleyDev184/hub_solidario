import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para buscar empréstimos por solicitante.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class GetLoansByApplicantUseCase {
  final LoanRepository repository;

  const GetLoansByApplicantUseCase({required this.repository});

  AsyncResult<List<Loan>> call({required String applicantId}) async {
    try {
      return await repository.getLoansByApplicant(applicantId: applicantId);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos do solicitante: ${e.toString()}'),
      );
    }
  }
}
