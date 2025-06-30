import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/update_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para atualizar um empréstimo existente.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class UpdateLoanUseCase {
  final CategoryRepository _repository;

  UpdateLoanUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a atualização de um empréstimo.
  ///
  /// [id] - ID do empréstimo a ser atualizado
  /// [updateLoanDTO] - Dados para atualização do empréstimo
  ///
  /// Retorna [Success] com o empréstimo atualizado ou [Failure] em caso de erro.
  AsyncResult<Loan> call({
    required String id,
    required UpdateLoanDTO updateLoanDTO,
  }) async {
    try {
      // Validações básicas
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do empréstimo não pode estar vazio'));
      }

      if (updateLoanDTO.isEmpty) {
        return Failure(
          Exception('Pelo menos um campo deve ser fornecido para atualização'),
        );
      }

      if (!updateLoanDTO.isValid) {
        return Failure(Exception('Dados de atualização inválidos'));
      }

      // Validações específicas de negócio
      if (updateLoanDTO.reason != null &&
          updateLoanDTO.reason!.trim().length < 10) {
        return Failure(
          Exception('Motivo do empréstimo deve ter pelo menos 10 caracteres'),
        );
      }

      // Executa a operação no repositório
      final result = await _repository.updateLoan(
        id: id,
        updateLoanDTO: updateLoanDTO,
      );

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao atualizar empréstimo: ${e.toString()}'),
      );
    }
  }
}
