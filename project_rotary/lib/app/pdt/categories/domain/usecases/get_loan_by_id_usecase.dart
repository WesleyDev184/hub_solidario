import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/loans/domain/entities/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar um empréstimo por ID.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetLoanByIdUseCase {
  final CategoryRepository _repository;

  GetLoanByIdUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de um empréstimo por ID.
  ///
  /// [id] - ID do empréstimo a ser buscado
  ///
  /// Retorna [Success] com o empréstimo encontrado ou [Failure] em caso de erro.
  AsyncResult<Loan> call({required String id}) async {
    try {
      // Validação básica
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do empréstimo não pode estar vazio'));
      }

      // Executa a operação no repositório
      final result = await _repository.getLoanById(id: id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar empréstimo: ${e.toString()}'),
      );
    }
  }
}
