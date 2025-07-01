import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para realizar login no sistema.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase({required this.repository});

  AsyncResult<AuthData> call({required SignInDTO signInDTO}) async {
    try {
      return await repository.signin(signInDTO: signInDTO);
    } catch (e) {
      return Failure(Exception('Erro ao fazer login: ${e.toString()}'));
    }
  }
}
