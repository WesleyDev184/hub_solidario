import 'package:project_rotary/app/pdt/loans/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Repository interface para operações de empréstimos.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
abstract class LoanRepository {
  /// Cria um novo empréstimo
  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO});

  /// Busca todos os empréstimos
  AsyncResult<List<Loan>> getAllLoans();

  /// Busca um empréstimo por ID
  AsyncResult<Loan> getLoanById({required String id});

  /// Atualiza um empréstimo existente
  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  });

  /// Deleta um empréstimo
  AsyncResult<String> deleteLoan({required String id});

  /// Finaliza um empréstimo (marca como retornado)
  AsyncResult<Loan> finalizeLoan({required String id});

  /// Busca empréstimos por solicitante
  AsyncResult<List<Loan>> getLoansByApplicant({required String applicantId});

  /// Busca empréstimos ativos
  AsyncResult<List<Loan>> getActiveLoans();

  /// Busca empréstimos finalizados
  AsyncResult<List<Loan>> getCompletedLoans();
}
