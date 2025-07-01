import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para verificar se o usuário está logado.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class IsLoggedInUseCase {
  final AuthRepository repository;

  const IsLoggedInUseCase({required this.repository});

  AsyncResult<bool> call() async {
    try {
      return await repository.isLoggedIn();
    } catch (e) {
      return Failure(Exception('Erro ao verificar login: ${e.toString()}'));
    }
  }
}
