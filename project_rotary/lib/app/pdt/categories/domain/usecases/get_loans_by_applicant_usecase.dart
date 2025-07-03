import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar empréstimos por solicitante.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetLoansByApplicantUseCase {
  final CategoryRepository _repository;

  GetLoansByApplicantUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de empréstimos por solicitante.
  ///
  /// [applicantId] - ID do solicitante
  ///
  /// Retorna [Success] com a lista de empréstimos ou [Failure] em caso de erro.
  AsyncResult<List<Loan>> call({required String applicantId}) async {
    try {
      // Validação básica
      if (applicantId.trim().isEmpty) {
        return Failure(Exception('ID do solicitante não pode estar vazio'));
      }

      // Executa a operação no repositório
      final result = await _repository.getLoansByApplicant(
        applicantId: applicantId,
      );

      return result;
    } catch (e) {
      return Failure(
        Exception(
          'Erro inesperado ao buscar empréstimos do solicitante: ${e.toString()}',
        ),
      );
    }
  }
}
