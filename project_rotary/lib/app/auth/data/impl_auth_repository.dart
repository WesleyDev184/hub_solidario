import 'package:flutter/widgets.dart';
import 'package:project_rotary/app/auth/data/auth_storage.dart';
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
class ImplAuthRepository implements AuthRepository {
  final ApiClient _apiClient;

  // Cache local do usuário e dados de autenticação
  static User? _currentUser;
  static AuthData? _currentAuthData;
  static bool _isLoadingUser =
      false; // Flag para evitar múltiplas requisições simultâneas

  ImplAuthRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient() {
    // Carrega dados salvos na inicialização
    _loadSavedAuthData();
  }

  /// Carrega dados de autenticação salvos localmente
  Future<void> _loadSavedAuthData() async {
    try {
      final savedAuthData = await AuthStorage.getAuthData();
      final savedUser = await AuthStorage.getUser();

      if (savedAuthData != null && !savedAuthData.isExpired) {
        _currentAuthData = savedAuthData;
        _apiClient.setAccessToken(savedAuthData.accessToken);
        debugPrint('AuthData carregado do armazenamento local');
      }

      if (savedUser != null) {
        _currentUser = savedUser;
        debugPrint(
          'Usuário carregado do armazenamento local: ${savedUser.name}',
        );
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados salvos: $e');
    }
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
        (data) async {
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

          // Salva os dados de autenticação localmente
          await AuthStorage.saveAuthData(authData);

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
        (data) async {
          // Limpa os dados locais e do armazenamento
          _currentUser = null;
          _currentAuthData = null;
          _isLoadingUser = false;
          _apiClient.clearAccessToken();
          await AuthStorage.clearAuthData();

          return Success('Logout realizado com sucesso');
        },
        (error) async {
          // Mesmo em caso de erro na API, limpa os dados locais
          _currentUser = null;
          _currentAuthData = null;
          _isLoadingUser = false;
          _apiClient.clearAccessToken();
          await AuthStorage.clearAuthData();

          return Success('Logout realizado localmente');
        },
      );
    } catch (e) {
      // Em caso de erro, limpa os dados locais
      _currentUser = null;
      _currentAuthData = null;
      _isLoadingUser = false;
      _apiClient.clearAccessToken();
      await AuthStorage.clearAuthData();

      return Success('Logout realizado localmente');
    }
  }

  @override
  AsyncResult<bool> isLoggedIn() async {
    try {
      // Primeiro verifica os dados em memória
      final isLoggedInMemory =
          _currentAuthData != null &&
          !_currentAuthData!.isExpired &&
          _currentUser != null;

      if (isLoggedInMemory) {
        return Success(true);
      }

      // Se não estiver em memória, verifica o armazenamento local
      final isLoggedInStorage = await AuthStorage.isLoggedIn();

      if (isLoggedInStorage) {
        // Carrega os dados do armazenamento se estiverem válidos
        await _loadSavedAuthData();
        return Success(true);
      }

      return Success(false);
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

      _isLoadingUser = true;

      // Caso contrário, busca da API - GET /user
      final result = await _apiClient.get(ApiEndpoints.user, useAuth: true);

      return result.fold(
        (data) async {
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
          _isLoadingUser = false;

          // Salva o usuário no armazenamento local
          await AuthStorage.saveUser(user);

          debugPrint('ImplAuthRepository - Usuário parseado: $user');
          debugPrint(
            'ImplAuthRepository - Banco do usuário: ${user.orthopedicBank?.name}',
          );
          return Success(user);
        },
        (error) {
          _isLoadingUser = false;
          return Failure(
            Exception('Erro ao obter usuário atual: ${error.toString()}'),
          );
        },
      );
    } catch (e) {
      _isLoadingUser = false;
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

  /// Verifica e restaura uma sessão salva anteriormente
  /// Útil para chamar na inicialização do app
  @override
  AsyncResult<bool> restoreSession() async {
    try {
      final isLoggedIn = await AuthStorage.isLoggedIn();

      if (isLoggedIn) {
        await _loadSavedAuthData();

        // Verifica se os dados carregados são válidos
        if (_currentAuthData != null && !_currentAuthData!.isExpired) {
          debugPrint('Sessão restaurada com sucesso');
          return Success(true);
        }
      }

      return Success(false);
    } catch (e) {
      return Failure(Exception('Erro ao restaurar sessão: ${e.toString()}'));
    }
  }

  /// Libera recursos
  void dispose() {
    _apiClient.dispose();
  }
}
