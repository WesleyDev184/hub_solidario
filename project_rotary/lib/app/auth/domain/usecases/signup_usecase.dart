import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:result_dart/result_dart.dart';

/// Use Case para realizar cadastro no sistema.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase({required this.repository});

  AsyncResult<String> call({required SignUpDTO signUpDTO}) async {
    try {
      return await repository.signup(signUpDTO: signUpDTO);
    } catch (e) {
      return Failure(Exception('Erro ao criar conta: ${e.toString()}'));
    }
  }
}
