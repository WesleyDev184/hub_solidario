import 'package:flutter/material.dart';
import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  bool isLoading = false;
  String? error;

  Future<bool> signin({required SignInDTO signInDTO}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authRepository.signin(signInDTO: signInDTO);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({required SignUpDTO signUpDTO}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authRepository.signup(signUpDTO: signUpDTO);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
