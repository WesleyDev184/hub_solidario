import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:project_rotary/app/auth/domain/entities/orthopedic_bank.dart';
import 'package:project_rotary/app/auth/domain/entities/user.dart';
import 'package:result_dart/result_dart.dart';

/// Repository interface para operações de autenticação.
/// Segue o padrão Clean Architecture implementado em loans, applicants e categories.
abstract class AuthRepository {
  /// Realiza login no sistema retornando AccessTokenResponse
  AsyncResult<AuthData> signin({required SignInDTO signInDTO});

  /// Realiza cadastro no sistema retornando o ID do usuário criado
  AsyncResult<String> signup({required SignUpDTO signUpDTO});

  /// Realiza logout do sistema
  AsyncResult<String> logout();

  /// Verifica se o usuário está logado
  AsyncResult<bool> isLoggedIn();

  /// Obtém dados do usuário atual
  AsyncResult<User> getCurrentUser();

  /// Busca todos os bancos ortopédicos disponíveis
  AsyncResult<List<OrthopedicBank>> getOrthopedicBanks();

  /// Atualiza o token de acesso
  AsyncResult<AuthData> refreshToken({required String refreshToken});

  /// Verifica se o token é válido
  AsyncResult<bool> validateToken({required String token});
}
