import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para obter dados do usuário atual.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase({required this.repository});

  AsyncResult<User> call() async {
    try {
      return await repository.getCurrentUser();
    } catch (e) {
      return Failure(Exception('Erro ao obter usuário atual: ${e.toString()}'));
    }
  }
}
