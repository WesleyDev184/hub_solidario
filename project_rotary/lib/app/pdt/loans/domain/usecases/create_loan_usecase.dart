import 'package:project_rotary/app/pdt/loans/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para criar novos empréstimos.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class CreateLoanUseCase {
  final LoanRepository repository;

  const CreateLoanUseCase({required this.repository});

  AsyncResult<Loan> call({required CreateLoanDTO createLoanDTO}) async {
    try {
      return await repository.createLoan(createLoanDTO: createLoanDTO);
    } catch (e) {
      return Failure(Exception('Erro ao criar empréstimo: ${e.toString()}'));
    }
  }
}
