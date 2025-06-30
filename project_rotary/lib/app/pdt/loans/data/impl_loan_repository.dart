import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

class ImplLoanRepository implements LoanRepository {
  @override
  AsyncResult<Loan> updateLoan({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 10 == 0) {
        return Failure(Exception('Erro ao atualizar empréstimo'));
      }

      // Simular resposta da API - buscar dados atuais primeiro
      final updatedLoanData = {
        'id': id,
        'applicantId': 'applicant-001',
        'responsibleId': 'responsible-001',
        'itemId': 'item-001',
        'reason': updateLoanDTO.reason ?? 'Motivo atualizado',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'returnedAt':
            updateLoanDTO.isActive == false
                ? DateTime.now().toIso8601String()
                : null,
      };

      final loan = Loan.fromJson(updatedLoanData);
      return Success(loan);
    } catch (e) {
      return Failure(
        Exception('Erro ao atualizar empréstimo: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<Loan> getLoanById({required String id}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Simular busca de empréstimo por ID
      final loanData = {
        'id': id,
        'applicantId': 'applicant-001',
        'responsibleId': 'responsible-001',
        'itemId': 'item-001',
        'reason': 'Empréstimo para uso temporário',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'returnedAt': null,
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(Exception('Erro ao buscar empréstimo: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<String> finalizeLoan({required String id}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 12 == 0) {
        return Failure(Exception('Erro ao finalizar empréstimo'));
      }

      // Simular finalização do empréstimo
      return Success('Empréstimo finalizado com sucesso');
    } catch (e) {
      return Failure(
        Exception('Erro ao finalizar empréstimo: ${e.toString()}'),
      );
    }
  }
}
