import 'package:app/core/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../models/auth_models.dart';

/// Repositório para operações de autenticação
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Realiza login do usuário
  AsyncResult<AccessTokenResponse> login(
    String email,
    String password,
    String deviceToken, {
    bool useCookies = false,
    bool useSessionCookies = false,
  }) async {
    try {
      debugPrint('Attempting login for: $email');

      final request = LoginRequest(
        email: email,
        password: password,
        deviceToken: deviceToken,
      );

      // Constrói query parameters se necessário
      Map<String, String>? queryParams;
      if (useCookies || useSessionCookies) {
        queryParams = {};
        if (useCookies) queryParams['useCookies'] = 'true';
        if (useSessionCookies) queryParams['useSessionCookies'] = 'true';
      }

      final result = await _apiClient.post(
        '/login',
        request.toJson(),
        useAuth: false,
      );

      return result.fold(
        (success) {
          try {
            final tokenResponse = AccessTokenResponse.fromJson(success);
            return Success(tokenResponse);
          } catch (e) {
            return Failure(Exception('Erro ao processar resposta do login'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro interno no login: ${e.toString()}'));
    }
  }

  /// Realiza logout do usuário
  AsyncResult<bool> logout() async {
    await _apiClient.post('/logout', {}, useAuth: true);
    configureApiClientToken(null);
    return const Success(true);
  }

  /// Obtém o usuário atual
  AsyncResult<User> getCurrentUser() async {
    try {
      final result = await _apiClient.get('/user', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro ao obter usuário atual: ${e.toString()}'));
    }
  }

  /// Cria um novo usuário
  AsyncResult<bool> createUser(CreateUserRequest request) async {
    try {
      final result = await _apiClient.post(
        '/user',
        request.toJson(),
        useAuth: false,
      );

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<dynamic>.fromJson(
              success,
              (json) => json,
            );

            if (response.success) {
              return const Success(true);
            } else {
              return Failure(
                Exception(response.message ?? 'Falha ao criar usuário'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar resposta de criação'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro ao criar usuário: ${e.toString()}'));
    }
  }

  /// Atualiza o usuário atual
  AsyncResult<bool> updateCurrentUser(UpdateUserRequest request) async {
    try {
      final result = await _apiClient.patch(
        '/user',
        request.toJson(),
        useAuth: true,
      );

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<dynamic>.fromJson(
              success,
              (json) => json,
            );

            if (response.success) {
              return const Success(true);
            } else {
              return Failure(
                Exception(response.message ?? 'Falha ao atualizar usuário'),
              );
            }
          } catch (e) {
            return Failure(
              Exception('Erro ao processar resposta de atualização'),
            );
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro ao atualizar usuário: ${e.toString()}'));
    }
  }

  /// Obtém usuários por banco ortopédico
  AsyncResult<List<User>> getUsersByOrthopedicBank(
    String orthopedicBankId,
  ) async {
    try {
      final result = await _apiClient.get(
        '/users/orthopedic-bank/$orthopedicBankId',
        useAuth: true,
      );

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<List<User>>.fromJson(success, (
              json,
            ) {
              final list = json as List<dynamic>;
              return list
                  .map((item) => User.fromJson(item as Map<String, dynamic>))
                  .toList();
            });

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuários não encontrados'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar lista de usuários'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao obter usuários por banco: ${e.toString()}'),
      );
    }
  }

  /// Obtém todos os usuários forçando busca do servidor
  AsyncResult<List<User>> getAllUsersFromServer() async {
    try {
      final result = await _apiClient.get('/users', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<List<User>>.fromJson(success, (
              json,
            ) {
              final list = json as List<dynamic>;
              return list
                  .map((item) => User.fromJson(item as Map<String, dynamic>))
                  .toList();
            });

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuários não encontrados'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar lista de usuários'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao obter usuários do servidor: ${e.toString()}'),
      );
    }
  }

  /// Obtém usuário por ID
  AsyncResult<User> getUserById(String id) async {
    try {
      final result = await _apiClient.get('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro ao obter usuário: ${e.toString()}'));
    }
  }

  /// Deleta usuário por ID
  AsyncResult<bool> deleteUser(String id) async {
    try {
      final result = await _apiClient.delete('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<dynamic>.fromJson(
              success,
              (json) => json,
            );

            if (response.success) {
              return const Success(true);
            } else {
              return Failure(
                Exception(response.message ?? 'Falha ao deletar usuário'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar resposta de deleção'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro ao deletar usuário: ${e.toString()}'));
    }
  }

  /// Obtém o usuário atual forçando busca do servidor
  AsyncResult<User> getCurrentUserFromServer() async {
    try {
      debugPrint('Getting current user from server (forced refresh)');

      final result = await _apiClient.get('/user', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao obter usuário atual do servidor: ${e.toString()}'),
      );
    }
  }

  /// Obtém usuário por ID forçando busca do servidor
  AsyncResult<User> getUserByIdFromServer(String id) async {
    try {
      final result = await _apiClient.get('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              return Success(response.data!);
            } else {
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(
        Exception('Erro ao obter usuário do servidor: ${e.toString()}'),
      );
    }
  }

  void configureApiClientToken(String? token) {
    if (token != null) {
      _apiClient.setAccessToken(token);
    } else {
      _apiClient.clearAccessToken();
    }
  }
}
