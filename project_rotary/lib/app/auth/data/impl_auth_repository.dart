import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:result_dart/result_dart.dart';

import '../domain/auth_repository.dart';

class ImplAuthRepository implements AuthRepository {
  @override
  AsyncResult<String> signin({required SignInDTO signInDTO}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (signInDTO.email != 'admin@email.com' ||
        signInDTO.password != '123456') {
      return Failure(Exception('Credenciais inválidas'));
    }

    debugPrint('Login realizado com sucesso');
    return Success('Login realizado com sucesso');
  }

  @override
  AsyncResult<String> signup({required SignUpDTO signUpDTO}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (signUpDTO.password != signUpDTO.confirmPassword) {
      return Failure(Exception('As senhas não coincidem'));
    }
    debugPrint('Cadastro realizado com sucesso');
    return Success('Cadastro realizado com sucesso');
  }

  @override
  AsyncResult<String> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success('Logout realizado com sucesso');
  }

  @override
  AsyncResult<bool> isLoggedIn() async {
    return Success(false);
  }
}
