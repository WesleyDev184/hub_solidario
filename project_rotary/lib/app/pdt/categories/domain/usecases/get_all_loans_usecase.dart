import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/loan.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar todos os empréstimos.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetAllLoansUseCase {
  final CategoryRepository _repository;

  GetAllLoansUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de todos os empréstimos.
  ///
  /// Retorna [Success] com a lista de empréstimos ou [Failure] em caso de erro.
  AsyncResult<List<Loan>> call() async {
    try {
      // Executa a operação no repositório
      final result = await _repository.getLoans();

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar empréstimos: ${e.toString()}'),
      );
    }
  }
}
