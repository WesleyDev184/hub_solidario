import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para realizar logout do sistema.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase({required this.repository});

  AsyncResult<String> call() async {
    try {
      return await repository.logout();
    } catch (e) {
      return Failure(Exception('Erro ao fazer logout: ${e.toString()}'));
    }
  }
}
