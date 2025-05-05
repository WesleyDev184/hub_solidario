import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';

import '../domain/auth_repository.dart';

class ImplAuthRepository implements AuthRepository {
  @override
  Future<void> signin({required SignInDTO signInDTO}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (signInDTO.email != 'admin@email.com' ||
        signInDTO.password != '123456') {
      throw Exception('Credenciais inválidas');
    }

    debugPrint('Login realizado com sucesso');
  }

  @override
  Future<void> signup({required SignUpDTO signUpDTO}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (signUpDTO.password != signUpDTO.confirmPassword) {
      throw Exception('As senhas não coincidem');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<bool> isLoggedIn() async {
    return false;
  }
}
