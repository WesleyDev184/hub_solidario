import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:result_dart/result_dart.dart';

abstract class AuthRepository {
  AsyncResult<String> signin({required SignInDTO signInDTO});
  AsyncResult<String> signup({required SignUpDTO signUpDTO});
  AsyncResult<String> logout();
  AsyncResult<bool> isLoggedIn();
}
