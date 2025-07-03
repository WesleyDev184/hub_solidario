import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para deletar um empréstimo.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class DeleteLoanUseCase {
  final CategoryRepository _repository;

  DeleteLoanUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a exclusão de um empréstimo.
  ///
  /// [id] - ID do empréstimo a ser deletado
  ///
  /// Retorna [Success] com mensagem de sucesso ou [Failure] em caso de erro.
  AsyncResult<String> call({required String id}) async {
    try {
      // Validação básica
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do empréstimo não pode estar vazio'));
      }

      // Executa a operação no repositório
      final result = await _repository.deleteLoan(id: id);

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao deletar empréstimo: ${e.toString()}'),
      );
    }
  }
}
