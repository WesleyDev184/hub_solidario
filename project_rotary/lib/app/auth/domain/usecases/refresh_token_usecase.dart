import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para atualizar o token de acesso.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class RefreshTokenUseCase {
  final AuthRepository repository;

  const RefreshTokenUseCase({required this.repository});

  AsyncResult<AuthData> call({required String refreshToken}) async {
    try {
      return await repository.refreshToken(refreshToken: refreshToken);
    } catch (e) {
      return Failure(Exception('Erro ao atualizar token: ${e.toString()}'));
    }
  }
}
