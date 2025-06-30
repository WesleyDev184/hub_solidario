import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/dto/create_loan_dto.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para criar um novo empréstimo.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class CreateLoanUseCase {
  final CategoryRepository _repository;

  CreateLoanUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a criação de um novo empréstimo.
  ///
  /// [createLoanDTO] - Dados do empréstimo a ser criado
  ///
  /// Retorna [Success] com o empréstimo criado ou [Failure] em caso de erro.
  AsyncResult<Loan> call({required CreateLoanDTO createLoanDTO}) async {
    try {
      // Validações de negócio
      if (!createLoanDTO.isValid) {
        return Failure(Exception('Dados do empréstimo são inválidos'));
      }

      // Validações específicas de negócio
      if (createLoanDTO.reason.trim().length < 10) {
        return Failure(
          Exception('Motivo do empréstimo deve ter pelo menos 10 caracteres'),
        );
      }

      // Executa a operação no repositório
      final result = await _repository.createLoan(createLoanDTO: createLoanDTO);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao criar empréstimo: ${e.toString()}'),
      );
    }
  }
}
