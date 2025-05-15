import 'package:flutter/material.dart';
import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:result_dart/result_dart.dart'; // make sure result_dart is imported

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  bool isLoading = false;
  String? error;

  AsyncResult<String> signin({required SignInDTO signInDTO}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.signin(signInDTO: signInDTO);

    isLoading = false;
    notifyListeners();

    return result;
  }

  AsyncResult<String> signup({required SignUpDTO signUpDTO}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    final result = await _authRepository.signup(signUpDTO: signUpDTO);

    isLoading = false;
    notifyListeners();

    return result;
  }
}
