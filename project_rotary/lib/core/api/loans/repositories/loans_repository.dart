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
}
