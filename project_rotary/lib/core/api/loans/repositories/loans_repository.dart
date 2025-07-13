import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/api_config.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de loans via API
class LoansRepository {
  final ApiClient _apiClient;

  const LoansRepository(this._apiClient);

  /// Busca todos os loans
  AsyncResult<List<LoanListItem>> getLoans() async {
    try {
      final result = await _apiClient.get(ApiEndpoints.loans, useAuth: true);

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final loansData = data['data'] as List;
            final loans =
                loansData
                    .map(
                      (json) =>
                          LoanListItem.fromJson(json as Map<String, dynamic>),
                    )
                    .toList();
            return Success(loans);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao buscar empréstimos'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos empréstimos: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um loan por ID
  AsyncResult<Loan> getLoanById(String loanId) async {
    try {
      final result = await _apiClient.get(
        ApiEndpoints.loanById(loanId),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final loan = Loan.fromJson(data['data'] as Map<String, dynamic>);
            return Success(loan);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Empréstimo não encontrado'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do empréstimo: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo loan
  AsyncResult<Loan> createLoan(CreateLoanRequest request) async {
    try {
      final result = await _apiClient.post(
        ApiEndpoints.loans,
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final loan = Loan.fromJson(data['data'] as Map<String, dynamic>);
            return Success(loan);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao criar empréstimo'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da criação: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um loan existente
  AsyncResult<Loan> updateLoan(String loanId, UpdateLoanRequest request) async {
    try {
      final result = await _apiClient.patch(
        ApiEndpoints.loanById(loanId),
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final loan = Loan.fromJson(data['data'] as Map<String, dynamic>);
            return Success(loan);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao atualizar empréstimo'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da atualização: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um loan
  AsyncResult<bool> deleteLoan(String loanId) async {
    try {
      final result = await _apiClient.delete(
        ApiEndpoints.loanById(loanId),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true) {
            return const Success(true);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao deletar empréstimo'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  // === ESTATÍSTICAS ===

  /// Obtém estatísticas dos loans
  AsyncResult<Map<String, dynamic>> getLoansStatistics() async {
    try {
      final allLoansResult = await getLoans();

      return allLoansResult.fold((loans) {
        final totalLoans = loans.length;
        final activeLoans = loans.where((loan) => loan.isActive).length;
        final returnedLoans = loans.where((loan) => !loan.isActive).length;

        // Loans em atraso (ativos há mais de 30 dias)
        final now = DateTime.now();
        final overdueLoans =
            loans.where((loan) {
              if (!loan.isActive) return false;
              final daysSinceLoan = now.difference(loan.createdAt).inDays;
              return daysSinceLoan > 30;
            }).length;

        // Estatísticas por mês (últimos 12 meses)
        final monthlyStats = <String, int>{};
        for (int i = 0; i < 12; i++) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final monthKey =
              '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

          final monthLoans =
              loans.where((loan) {
                final loanDate = loan.createdAt;
                return loanDate.year == monthDate.year &&
                    loanDate.month == monthDate.month;
              }).length;

          monthlyStats[monthKey] = monthLoans;
        }

        final statistics = {
          'totalLoans': totalLoans,
          'activeLoans': activeLoans,
          'returnedLoans': returnedLoans,
          'overdueLoans': overdueLoans,
          'returnRate':
              totalLoans > 0
                  ? (returnedLoans / totalLoans * 100).toStringAsFixed(1)
                  : '0.0',
          'monthlyStats': monthlyStats,
          'averageLoanDuration': _calculateAverageLoanDuration(loans),
        };

        return Success(statistics);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao calcular estatísticas: $e'));
    }
  }

  /// Calcula a duração média dos empréstimos
  double _calculateAverageLoanDuration(List<LoanListItem> loans) {
    final completedLoans =
        loans
            .where((loan) => !loan.isActive && loan.returnDate != null)
            .toList();

    if (completedLoans.isEmpty) return 0.0;

    final totalDays = completedLoans.fold<int>(0, (sum, loan) {
      final duration = loan.returnDate!.difference(loan.createdAt).inDays;
      return sum + duration;
    });

    return totalDays / completedLoans.length;
  }
}
