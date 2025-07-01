import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para validar um token de acesso.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class ValidateTokenUseCase {
  final AuthRepository repository;

  const ValidateTokenUseCase({required this.repository});

  AsyncResult<bool> call({required String token}) async {
    try {
      return await repository.validateToken(token: token);
    } catch (e) {
      return Failure(Exception('Erro ao validar token: ${e.toString()}'));
    }
  }
}
