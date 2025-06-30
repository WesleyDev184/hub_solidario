import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar usuários que podem ser responsáveis.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetResponsiblesUseCase {
  final CategoryRepository _repository;

  GetResponsiblesUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de usuários que podem ser responsáveis por empréstimos.
  ///
  /// Retorna [Success] com a lista de responsáveis ou [Failure] em caso de erro.
  AsyncResult<List<User>> call() async {
    try {
      // Executa a operação no repositório
      final result = await _repository.getResponsibles();

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar responsáveis: ${e.toString()}'),
      );
    }
  }
}
