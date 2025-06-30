import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar usuários que podem ser solicitantes.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetApplicantsUseCase {
  final CategoryRepository _repository;

  GetApplicantsUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de usuários que podem solicitar empréstimos.
  ///
  /// Retorna [Success] com a lista de solicitantes ou [Failure] em caso de erro.
  AsyncResult<List<User>> call() async {
    try {
      // Executa a operação no repositório
      final result = await _repository.getApplicants();

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar solicitantes: ${e.toString()}'),
      );
    }
  }
}
