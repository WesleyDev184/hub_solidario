import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:project_rotary/app/auth/domain/entities/orthopedic_bank.dart';
import 'package:project_rotary/app/auth/domain/entities/user.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/api_config.dart';
import 'package:result_dart/result_dart.dart';

/// Implementação do repositório de autenticação.
/// Segue o padrão Clean Architecture e faz chamadas reais para a API Rotary.
class ImplAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  // Cache local do usuário e dados de autenticação
  static User? _currentUser;
  static AuthData? _currentAuthData;

  ImplAuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient() {
    // TODO: Configurar API Key se necessária
    // _apiClient.setApiKey('your-api-key-here');
  }

  @override
  AsyncResult<AuthData> signin({required SignInDTO signInDTO}) async {
    try {
      // Chamada para POST /login conforme documentação OpenAPI
      final result = await _apiClient.post(ApiEndpoints.login, {
        'email': signInDTO.email,
        'password': signInDTO.password,
      });

      return result.fold(
        (data) {
          // Parse da resposta AccessTokenResponse
          final authData = AuthData(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
            expiresIn: (data['expiresIn'] as num).toInt(),
            tokenType: data['tokenType'] as String? ?? 'Bearer',
          );

          _currentAuthData = authData;

          // Define o token para futuras requisições
          _apiClient.setAccessToken(authData.accessToken);

          debugPrint('Login realizado com sucesso');
          return Success(authData);
        },
        (error) =>
            Failure(Exception('Erro ao fazer login: ${error.toString()}')),
      );
    } catch (e) {
      return Failure(Exception('Erro ao fazer login: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<String> signup({required SignUpDTO signUpDTO}) async {
    try {
      // Validação local
      if (signUpDTO.password != signUpDTO.confirmPassword) {
        return Failure(Exception('As senhas não coincidem'));
      }

      // Chamada para POST /user conforme documentação OpenAPI
      final result = await _apiClient.post(ApiEndpoints.user, {
        'name': signUpDTO.name,
        'email': signUpDTO.email,
        'password': signUpDTO.password,
        'phoneNumber': signUpDTO.phoneNumber,
        'orthopedicBankId': signUpDTO.orthopedicBankId,
      });

      return result.fold(
        (data) {
          // A API retorna o ID do usuário criado
          final userId =
              data['id'] as String? ?? data['data']?['id'] as String?;

          if (userId != null) {
            debugPrint('Cadastro realizado com sucesso - ID: $userId');
            return Success(userId);
          } else {
            return Failure(Exception('ID do usuário não retornado pela API'));
          }
        },
        (error) =>
            Failure(Exception('Erro ao criar conta: ${error.toString()}')),
      );
    } catch (e) {
      return Failure(Exception('Erro ao criar conta: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<String> logout() async {
    try {
      // Chamada para POST /logout conforme documentação OpenAPI
      final result = await _apiClient.post(
        ApiEndpoints.logout,
        {},
        useAuth: true,
      );

      return result.fold(
        (data) {
          // Limpa os dados locais
          _currentUser = null;
          _currentAuthData = null;
          _apiClient.clearAccessToken();

          return Success('Logout realizado com sucesso');
        },
        (error) {
          // Mesmo em caso de erro na API, limpa os dados locais
          _currentUser = null;
          _currentAuthData = null;
          _apiClient.clearAccessToken();

          return Success('Logout realizado localmente');
        },
      );
    } catch (e) {
      // Em caso de erro, limpa os dados locais
      _currentUser = null;
      _currentAuthData = null;
      _apiClient.clearAccessToken();

      return Success('Logout realizado localmente');
    }
  }

  @override
  AsyncResult<bool> isLoggedIn() async {
    try {
      final isLoggedIn =
          _currentAuthData != null &&
          !_currentAuthData!.isExpired &&
          _currentUser != null;
      return Success(isLoggedIn);
    } catch (e) {
      return Failure(Exception('Erro ao verificar login: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<User> getCurrentUser() async {
    try {
      // Se já temos o usuário em cache e está válido, retorna
      if (_currentUser != null &&
          _currentAuthData != null &&
          !_currentAuthData!.isExpired) {
        return Success(_currentUser!);
      }

      // Caso contrário, busca da API - GET /user
      final result = await _apiClient.get(ApiEndpoints.user, useAuth: true);

      return result.fold(
        (data) {
          // Parse do usuário da resposta da API
          final userData = data['data'] as Map<String, dynamic>? ?? data;

          // Debug: Log dos dados retornados pela API
          debugPrint('ImplAuthRepository - Dados do usuário da API: $userData');
          debugPrint(
            'ImplAuthRepository - orthopedicBank na resposta: ${userData['orthopedicBank']}',
          );

          // Usa o método fromMap para garantir que todos os campos sejam parseados corretamente
          final user = User.fromMap(userData);

          _currentUser = user;
          debugPrint('ImplAuthRepository - Usuário parseado: $user');
          debugPrint(
            'ImplAuthRepository - Banco do usuário: ${user.orthopedicBank?.name}',
          );
          return Success(user);
        },
        (error) => Failure(
          Exception('Erro ao obter usuário atual: ${error.toString()}'),
        ),
      );
    } catch (e) {
      return Failure(Exception('Erro ao obter usuário atual: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<List<OrthopedicBank>> getOrthopedicBanks() async {
    try {
      // Chamada para GET /orthopedic-banks conforme documentação OpenAPI
      final result = await _apiClient.get(ApiEndpoints.orthopedicBanks);

      return result.fold(
        (data) {
          // Parse da lista de bancos ortopédicos
          final banksData =
              data['data'] as List<dynamic>? ??
              data['orthopedicBanks'] as List<dynamic>? ??
              [];

          final banks =
              banksData.map((bankData) {
                final bank = bankData as Map<String, dynamic>;
                return OrthopedicBank(
                  id: bank['id'] as String,
                  name: bank['name'] as String,
                  city: bank['city'] as String,
                  createdAt: DateTime.parse(
                    bank['createdAt'] as String? ??
                        DateTime.now().toIso8601String(),
                  ),
                );
              }).toList();

          return Success(banks);
        },
        (error) => Failure(
          Exception('Erro ao buscar bancos ortopédicos: ${error.toString()}'),
        ),
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao buscar bancos ortopédicos: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<AuthData> refreshToken({required String refreshToken}) async {
    try {
      // TODO: Implementar endpoint de refresh token quando disponível na API
      // Por enquanto, retorna erro pois não há endpoint específico na documentação
      return Failure(Exception('Refresh token não implementado na API atual'));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar token: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<bool> validateToken({required String token}) async {
    try {
      // Tenta fazer uma requisição autenticada para validar o token
      _apiClient.setAccessToken(token);
      final result = await _apiClient.get(ApiEndpoints.user, useAuth: true);

      return result.fold((data) => Success(true), (error) => Success(false));
    } catch (e) {
      return Success(false);
    }
  }

  /// Libera recursos
  void dispose() {
    _apiClient.dispose();
  }
}
