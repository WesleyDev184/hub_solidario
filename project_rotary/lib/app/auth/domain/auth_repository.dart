import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';

abstract class AuthRepository {
  Future<void> signin({required SignInDTO signInDTO});
  Future<void> signup({required SignUpDTO signUpDTO});
  Future<void> logout();
  Future<bool> isLoggedIn();
}
