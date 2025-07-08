import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/api_config.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de loans via API
class LoansRepository {
  final ApiClient _apiClient;

  const LoansRepository(this._apiClient);

  /// Busca todos os loans
  AsyncResult<List<Loan>> getLoans({LoanFilters? filters}) async {
    try {
      final queryParams = filters?.toQueryParams();
      final result = await _apiClient.get(
        ApiEndpoints.loans,
        useAuth: true,
        queryParams: queryParams,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final loansData = data['data'] as List;
            final loans =
                loansData
                    .map((json) => Loan.fromJson(json as Map<String, dynamic>))
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

  // === MÉTODOS DE FILTRO ===

  /// Busca loans por applicant
  AsyncResult<List<Loan>> getLoansByApplicant(String applicantId) async {
    final filters = LoanFilters(applicantId: applicantId);
    return getLoans(filters: filters);
  }

  /// Busca loans por item
  AsyncResult<List<Loan>> getLoansByItem(String itemId) async {
    final filters = LoanFilters(itemId: itemId);
    return getLoans(filters: filters);
  }

  /// Busca loans por responsável
  AsyncResult<List<Loan>> getLoansByResponsible(String responsibleId) async {
    final filters = LoanFilters(responsibleId: responsibleId);
    return getLoans(filters: filters);
  }

  /// Busca loans ativos
  AsyncResult<List<Loan>> getActiveLoans() async {
    final filters = LoanFilters(isActive: true);
    return getLoans(filters: filters);
  }

  /// Busca loans inativos (devolvidos)
  AsyncResult<List<Loan>> getReturnedLoans() async {
    final filters = LoanFilters(isActive: false);
    return getLoans(filters: filters);
  }

  /// Busca loans em atraso
  AsyncResult<List<Loan>> getOverdueLoans() async {
    final filters = LoanFilters(isOverdue: true);
    return getLoans(filters: filters);
  }

  /// Busca loans por período
  AsyncResult<List<Loan>> getLoansByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filters = LoanFilters(
      createdAfter: startDate,
      createdBefore: endDate,
    );
    return getLoans(filters: filters);
  }

  // === REGRAS DE NEGÓCIO ===

  /// Verifica se um applicant pode criar um novo loan
  AsyncResult<bool> canApplicantCreateLoan(String applicantId) async {
    try {
      // Busca todos os loans ativos do applicant
      final activeLoansResult = await getLoansByApplicant(applicantId);

      return activeLoansResult.fold((loans) {
        // Filtra apenas os loans ativos
        final activeLoans = loans.where((loan) => loan.isActive).toList();

        // Regra: máximo de 3 loans ativos por applicant
        const maxActiveLoans = 3;

        if (activeLoans.length < maxActiveLoans) {
          return const Success(true);
        } else {
          return Failure(
            Exception(
              'Applicant já possui o máximo de $maxActiveLoans empréstimos ativos',
            ),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao verificar limite de empréstimos: $e'));
    }
  }

  /// Verifica se um item está disponível para empréstimo
  AsyncResult<bool> isItemAvailableForLoan(String itemId) async {
    try {
      // Busca todos os loans do item
      final loansResult = await getLoansByItem(itemId);

      return loansResult.fold((loans) {
        // Verifica se há algum loan ativo para este item
        final hasActiveLoan = loans.any((loan) => loan.isActive);

        if (!hasActiveLoan) {
          return const Success(true);
        } else {
          return Failure(Exception('Item já está emprestado e não disponível'));
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(
        Exception('Erro ao verificar disponibilidade do item: $e'),
      );
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
  double _calculateAverageLoanDuration(List<Loan> loans) {
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
