import 'package:app/core/api/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../models/auth_models.dart';
import '../services/auth_cache_service.dart';

/// Repositório para operações de autenticação
class AuthRepository {
  final ApiClient _apiClient;
  final AuthCacheService _cacheService;

  AuthRepository({
    required ApiClient apiClient,
    required AuthCacheService cacheService,
  }) : _apiClient = apiClient,
       _cacheService = cacheService;

  /// Realiza login do usuário
  AsyncResult<AccessTokenResponse> login(
    String email,
    String password, {
    bool useCookies = false,
    bool useSessionCookies = false,
  }) async {
    try {
      debugPrint('Attempting login for: $email');

      final request = LoginRequest(email: email, password: password);

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
            debugPrint('Login successful for: $email');
            return Success(tokenResponse);
          } catch (e) {
            debugPrint('Error parsing token response: $e');
            return Failure(Exception('Erro ao processar resposta do login'));
          }
        },
        (error) {
          debugPrint('Login failed for $email: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Login error: $e');
      return Failure(Exception('Erro interno no login: ${e.toString()}'));
    }
  }

  /// Realiza logout do usuário
  AsyncResult<bool> logout() async {
    try {
      debugPrint('Attempting logout');

      final result = await _apiClient.post('/logout', {}, useAuth: true);

      return result.fold(
        (success) {
          debugPrint('Logout successful');
          return const Success(true);
        },
        (error) {
          debugPrint('Logout failed: $error');
          // Mesmo se falhar no servidor, consideramos logout local bem-sucedido
          return const Success(true);
        },
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      // Em caso de erro, ainda consideramos logout bem-sucedido localmente
      return const Success(true);
    }
  }

  /// Obtém o usuário atual
  AsyncResult<User> getCurrentUser() async {
    try {
      debugPrint('Getting current user');

      // Primeiro, verifica se há um usuário válido no cache
      final cachedUser = await _cacheService.loadUser();
      if (cachedUser != null) {
        debugPrint('Current user loaded from cache: ${cachedUser.email}');
        return Success(cachedUser);
      }

      final result = await _apiClient.get('/user', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              debugPrint('Current user retrieved: ${response.data!.email}');

              // Salva o usuário no cache
              _cacheService.saveUser(response.data!);

              return Success(response.data!);
            } else {
              debugPrint('Failed to get current user: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing user response: $e');
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          debugPrint('Get current user failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get current user error: $e');
      return Failure(Exception('Erro ao obter usuário atual: ${e.toString()}'));
    }
  }

  /// Cria um novo usuário
  AsyncResult<bool> createUser(CreateUserRequest request) async {
    try {
      debugPrint('Creating user: ${request.email}');

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
              debugPrint('User created successfully: ${request.email}');
              return const Success(true);
            } else {
              debugPrint('Failed to create user: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Falha ao criar usuário'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing create user response: $e');
            return Failure(Exception('Erro ao processar resposta de criação'));
          }
        },
        (error) {
          debugPrint('Create user failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Create user error: $e');
      return Failure(Exception('Erro ao criar usuário: ${e.toString()}'));
    }
  }

  /// Atualiza o usuário atual
  AsyncResult<bool> updateCurrentUser(UpdateUserRequest request) async {
    try {
      debugPrint('Updating current user');

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
              debugPrint('User updated successfully');

              // Limpa o cache do usuário atual para forçar recarregamento
              _cacheService.saveUser(User.fromJson(request.toJson()));

              return const Success(true);
            } else {
              debugPrint('Failed to update user: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Falha ao atualizar usuário'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing update user response: $e');
            return Failure(
              Exception('Erro ao processar resposta de atualização'),
            );
          }
        },
        (error) {
          debugPrint('Update user failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Update user error: $e');
      return Failure(Exception('Erro ao atualizar usuário: ${e.toString()}'));
    }
  }

  /// Obtém usuários por banco ortopédico
  AsyncResult<List<User>> getUsersByOrthopedicBank(
    String orthopedicBankId,
  ) async {
    try {
      // Primeiro, tenta carregar do cache
      final cachedUsers = await _cacheService.loadAllUsers();
      if (cachedUsers.isNotEmpty) {
        debugPrint('Loaded ${cachedUsers.length} users from cache');
        // Retorna dados do cache imediatamente
        return Success(cachedUsers);
      }

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
              debugPrint(
                'Retrieved ${response.data!.length} users from server',
              );

              // Salva no cache
              _cacheService.saveAllUsers(response.data!);

              return Success(response.data!);
            } else {
              debugPrint('Failed to get users: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Usuários não encontrados'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing users response: $e');
            return Failure(Exception('Erro ao processar lista de usuários'));
          }
        },
        (error) {
          debugPrint('Get all users failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get users by bank error: $e');
      return Failure(
        Exception('Erro ao obter usuários por banco: ${e.toString()}'),
      );
    }
  }

  /// Obtém todos os usuários forçando busca do servidor
  AsyncResult<List<User>> getAllUsersFromServer() async {
    try {
      debugPrint('Getting all users from server (forced refresh)');

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
              debugPrint(
                'Retrieved ${response.data!.length} users from server (forced)',
              );

              // Atualiza o cache
              _cacheService.saveAllUsers(response.data!);

              return Success(response.data!);
            } else {
              debugPrint(
                'Failed to get users from server: ${response.message}',
              );
              return Failure(
                Exception(response.message ?? 'Usuários não encontrados'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing users response (forced): $e');
            return Failure(Exception('Erro ao processar lista de usuários'));
          }
        },
        (error) {
          debugPrint('Get all users from server failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get all users from server error: $e');
      return Failure(
        Exception('Erro ao obter usuários do servidor: ${e.toString()}'),
      );
    }
  }

  /// Obtém usuário por ID
  AsyncResult<User> getUserById(String id) async {
    try {
      debugPrint('Getting user by ID: $id');

      // Primeiro, verifica se o usuário já está no cache de todos os usuários
      final cachedUser = await _cacheService.findUserInAllUsers(id);
      if (cachedUser != null) {
        debugPrint('User loaded from cache: ${cachedUser.email}');
        return Success(cachedUser);
      }

      final result = await _apiClient.get('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              debugPrint('User retrieved: ${response.data!.email}');

              // Adiciona o usuário ao cache
              _cacheService.addUserToAllUsers(response.data!);

              return Success(response.data!);
            } else {
              debugPrint('Failed to get user: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing user by ID response: $e');
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          debugPrint('Get user by ID failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return Failure(Exception('Erro ao obter usuário: ${e.toString()}'));
    }
  }

  /// Deleta usuário por ID
  AsyncResult<bool> deleteUser(String id) async {
    try {
      debugPrint('Deleting user: $id');

      final result = await _apiClient.delete('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<dynamic>.fromJson(
              success,
              (json) => json,
            );

            if (response.success) {
              debugPrint('User deleted successfully: $id');

              // Remove o usuário do cache
              _cacheService.removeUserFromAllUsers(id);

              return const Success(true);
            } else {
              debugPrint('Failed to delete user: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Falha ao deletar usuário'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing delete user response: $e');
            return Failure(Exception('Erro ao processar resposta de deleção'));
          }
        },
        (error) {
          debugPrint('Delete user failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Delete user error: $e');
      return Failure(Exception('Erro ao deletar usuário: ${e.toString()}'));
    }
  }

  /// Carrega estado de autenticação do cache
  Future<AuthState> loadCachedAuthState() async {
    return await _cacheService.loadAuthState();
  }

  /// Salva estado de autenticação no cache
  Future<void> saveAuthState(AuthState state) async {
    await _cacheService.saveAuthState(state);
  }

  /// Limpa dados de autenticação do cache
  Future<void> clearAuthCache() async {
    await _cacheService.clearAuthData();
  }

  /// Verifica se há token válido no cache
  /// Verifica se há token válido no cache
  Future<bool> hasValidCachedToken() async {
    return await _cacheService.hasValidToken();
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
              debugPrint(
                'Current user retrieved from server: ${response.data!.email}',
              );

              // Atualiza o cache
              _cacheService.saveUser(response.data!);

              return Success(response.data!);
            } else {
              debugPrint(
                'Failed to get current user from server: ${response.message}',
              );
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing user response from server: $e');
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          debugPrint('Get current user from server failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get current user from server error: $e');
      return Failure(
        Exception('Erro ao obter usuário atual do servidor: ${e.toString()}'),
      );
    }
  }

  /// Obtém usuário por ID forçando busca do servidor
  AsyncResult<User> getUserByIdFromServer(String id) async {
    try {
      debugPrint('Getting user by ID from server: $id');

      final result = await _apiClient.get('/user/$id', useAuth: true);

      return result.fold(
        (success) {
          try {
            final response = ControllerResponse<User>.fromJson(
              success,
              (json) => User.fromJson(json as Map<String, dynamic>),
            );

            if (response.success && response.data != null) {
              debugPrint('User retrieved from server: ${response.data!.email}');

              // Atualiza o cache
              _cacheService.addUserToAllUsers(response.data!);

              return Success(response.data!);
            } else {
              debugPrint('Failed to get user from server: ${response.message}');
              return Failure(
                Exception(response.message ?? 'Usuário não encontrado'),
              );
            }
          } catch (e) {
            debugPrint('Error parsing user by ID response from server: $e');
            return Failure(Exception('Erro ao processar dados do usuário'));
          }
        },
        (error) {
          debugPrint('Get user by ID from server failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('Get user by ID from server error: $e');
      return Failure(
        Exception('Erro ao obter usuário do servidor: ${e.toString()}'),
      );
    }
  }

  /// Limpa apenas o cache de usuários (mantém dados de autenticação)
  Future<void> clearUsersCache() async {
    await _cacheService.clearAllUsers();
  }

  /// Verifica se há dados de autenticação salvos
  Future<bool> hasAuthData() async {
    return await _cacheService.hasAuthData();
  }

  /// Atualiza o cache de usuários com dados do servidor
  Future<void> refreshUsersCache() async {
    try {
      final result = await getAllUsersFromServer();
      if (result.isSuccess()) {
        debugPrint('Users cache refreshed successfully');
      }
    } catch (e) {
      debugPrint('Failed to refresh users cache: $e');
    }
  }
}
