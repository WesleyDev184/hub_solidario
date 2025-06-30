import 'package:project_rotary/app/pdt/categories/domain/category_repository.dart';
import 'package:project_rotary/app/pdt/categories/domain/models/user.dart';
import 'package:result_dart/result_dart.dart';

/// Use case para buscar todos os usuários.
/// Implementa o padrão Clean Architecture separando a lógica de negócio
/// da infraestrutura.
class GetAllUsersUseCase {
  final CategoryRepository _repository;

  GetAllUsersUseCase({required CategoryRepository repository})
    : _repository = repository;

  /// Executa a busca de todos os usuários.
  ///
  /// Retorna [Success] com a lista de usuários ou [Failure] em caso de erro.
  AsyncResult<List<User>> call() async {
    try {
      // Executa a operação no repositório
      final result = await _repository.getUsers();

      return result;
    } catch (e) {
      return Failure(
        Exception('Erro inesperado ao buscar usuários: ${e.toString()}'),
      );
    }
  }
}
