import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/loans/domain/loan_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Implementação do repository de empréstimos.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
/// Simula operações com dados usando delays e dados mockados.
class ImplLoanRepository implements LoanRepository {
  
  @override
  AsyncResult<Loan> createLoan({required CreateLoanDTO createLoanDTO}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 10 == 0) {
        return Failure(Exception('Erro ao criar empréstimo'));
      }

      // Simular resposta da API
      final loanData = {
        'id': 'loan-${DateTime.now().millisecondsSinceEpoch}',
        'applicantId': createLoanDTO.applicantId,
        'responsibleId': createLoanDTO.responsibleId,
        'itemId': createLoanDTO.itemId,
        'reason': createLoanDTO.reason,
        'createdAt': DateTime.now().toIso8601String(),
        'returnedAt': null,
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(
        Exception('Erro ao criar empréstimo: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Loan>> getAllLoans() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Simular dados de empréstimos
      final loansData = [
        {
          'id': 'loan-001',
          'applicantId': 'applicant-001',
          'responsibleId': 'responsible-001',
          'itemId': 'item-001',
          'reason': 'Evento do Rotary Club',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'returnedAt': null,
        },
        {
          'id': 'loan-002',
          'applicantId': 'applicant-002',
          'responsibleId': 'responsible-001',
          'itemId': 'item-002',
          'reason': 'Apresentação institucional',
          'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'returnedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': 'loan-003',
          'applicantId': 'applicant-003',
          'responsibleId': 'responsible-002',
          'itemId': 'item-003',
          'reason': 'Projeto comunitário',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'returnedAt': null,
        },
      ];

      final loans = loansData.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos: ${e.toString()}'),
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
        'reason': 'Evento do Rotary Club',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'returnedAt': null,
      };

      final loan = Loan.fromJson(loanData);
      return Success(loan);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimo: ${e.toString()}'),
      );
    }
  }

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
  AsyncResult<String> deleteLoan({required String id}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Simular possível erro
      if (DateTime.now().millisecond % 15 == 0) {
        return Failure(Exception('Erro ao deletar empréstimo'));
      }

      return Success('Empréstimo deletado com sucesso');
    } catch (e) {
      return Failure(
        Exception('Erro ao deletar empréstimo: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<Loan> finalizeLoan({required String id}) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Simular possível erro
      if (DateTime.now().millisecond % 12 == 0) {
        return Failure(Exception('Erro ao finalizar empréstimo'));
      }

      // Simular finalização do empréstimo
      final finalizedLoanData = {
        'id': id,
        'applicantId': 'applicant-001',
        'responsibleId': 'responsible-001',
        'itemId': 'item-001',
        'reason': 'Evento do Rotary Club',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'returnedAt': DateTime.now().toIso8601String(),
      };

      final loan = Loan.fromJson(finalizedLoanData);
      return Success(loan);
    } catch (e) {
      return Failure(
        Exception('Erro ao finalizar empréstimo: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Loan>> getLoansByApplicant({required String applicantId}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      // Simular busca de empréstimos por solicitante
      final loansData = [
        {
          'id': 'loan-001',
          'applicantId': applicantId,
          'responsibleId': 'responsible-001',
          'itemId': 'item-001',
          'reason': 'Evento do Rotary Club',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'returnedAt': null,
        },
        {
          'id': 'loan-004',
          'applicantId': applicantId,
          'responsibleId': 'responsible-002',
          'itemId': 'item-004',
          'reason': 'Reunião mensal',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'returnedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ];

      final loans = loansData.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos do solicitante: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Loan>> getActiveLoans() async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      // Simular busca de empréstimos ativos (não retornados)
      final loansData = [
        {
          'id': 'loan-001',
          'applicantId': 'applicant-001',
          'responsibleId': 'responsible-001',
          'itemId': 'item-001',
          'reason': 'Evento do Rotary Club',
          'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'returnedAt': null,
        },
        {
          'id': 'loan-003',
          'applicantId': 'applicant-003',
          'responsibleId': 'responsible-002',
          'itemId': 'item-003',
          'reason': 'Projeto comunitário',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'returnedAt': null,
        },
      ];

      final loans = loansData.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos ativos: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<List<Loan>> getCompletedLoans() async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      // Simular busca de empréstimos finalizados (retornados)
      final loansData = [
        {
          'id': 'loan-002',
          'applicantId': 'applicant-002',
          'responsibleId': 'responsible-001',
          'itemId': 'item-002',
          'reason': 'Apresentação institucional',
          'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'returnedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': 'loan-005',
          'applicantId': 'applicant-004',
          'responsibleId': 'responsible-002',
          'itemId': 'item-005',
          'reason': 'Workshop educacional',
          'createdAt': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
          'returnedAt': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        },
      ];

      final loans = loansData.map((data) => Loan.fromJson(data)).toList();
      return Success(loans);
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar empréstimos finalizados: ${e.toString()}'),
      );
    }
  }
}
