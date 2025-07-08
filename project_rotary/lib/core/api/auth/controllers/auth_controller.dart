import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

/// Controlador de autenticação com cache e manipulação otimista
class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthState _state = const AuthState(status: AuthStatus.unknown);
  AuthState get state => _state;

  bool get isAuthenticated => _state.isAuthenticated;
  bool get isUnauthenticated => _state.isUnauthenticated;
  bool get isLoading => _isLoading;

  User? get currentUser => _state.user;
  String? get accessToken => _state.token;

  bool _isLoading = false;
  StreamController<AuthState>? _stateController;

  AuthController({required AuthRepository repository})
    : _repository = repository;

  /// Stream do estado de autenticação
  Stream<AuthState> get stateStream {
    _stateController ??= StreamController<AuthState>.broadcast();
    return _stateController!.stream;
  }

  /// Inicializa o controlador carregando estado do cache
  Future<void> initialize() async {
    try {
      _setLoading(true);

      debugPrint('AuthController.initialize: Starting initialization');

      // Carrega estado do cache
      debugPrint('AuthController.initialize: Loading cached state');
      final cachedState = await _repository.loadCachedAuthState();
      _updateState(cachedState);

      debugPrint(
        'AuthController.initialize: Cached state loaded, authenticated: ${cachedState.isAuthenticated}',
      );

      // Se há token válido, tenta buscar dados atuais do usuário
      if (cachedState.isAuthenticated && !cachedState.isTokenExpired) {
        debugPrint(
          'AuthController.initialize: Token is valid, refreshing user data',
        );
        await _refreshCurrentUser();
      } else if (cachedState.token != null) {
        debugPrint('AuthController.initialize: Token expired, clearing cache');
        // Token expirado, limpa cache
        await logout();
      }

      debugPrint(
        'AuthController.initialize: Initialization completed successfully',
      );
    } catch (e) {
      debugPrint('AuthController.initialize: Error during initialization: $e');
      _updateState(const AuthState(status: AuthStatus.unauthenticated));
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza login com cache e manipulação otimista
  AsyncResult<User> login(String email, String password) async {
    try {
      _setLoading(true);

      debugPrint('AuthController.login: Starting login process for: $email');
      debugPrint('AuthController.login: Current state: ${_state.status}');

      // Realiza login
      debugPrint('AuthController.login: Calling repository.login');
      final loginResult = await _repository.login(email, password);

      return await loginResult.fold(
        (tokenResponse) async {
          debugPrint(
            'AuthController.login: Login API call successful, token received',
          );

          // Configura token no ApiClient IMEDIATAMENTE para próximas requisições
          debugPrint(
            'AuthController.login: Setting token in ApiClient immediately',
          );
          notifyListeners(); // Isso irá disparar o listener que configura o token no ApiClient

          // Força configuração do token manualmente também para garantir
          final tempState = AuthState(
            status: AuthStatus.authenticated,
            token: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            tokenExpiry: DateTime.now().add(
              Duration(seconds: tokenResponse.expiresIn),
            ),
          );
          _updateState(tempState);

          // Salva token no cache
          debugPrint('AuthController.login: Saving token to cache');
          await _repository.saveAuthState(tempState);

          // Aguarda um pouco para garantir que o token foi configurado
          await Future.delayed(const Duration(milliseconds: 100));

          // Busca dados do usuário
          debugPrint('AuthController.login: Fetching user data');
          final userResult = await _repository.getCurrentUser();

          return await userResult.fold(
            (user) async {
              debugPrint(
                'AuthController.login: User data fetched successfully',
              );

              // Estado final com usuário completo
              final finalState = AuthState(
                status: AuthStatus.authenticated,
                user: user,
                token: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                tokenExpiry: DateTime.now().add(
                  Duration(seconds: tokenResponse.expiresIn),
                ),
              );

              _updateState(finalState);
              await _repository.saveAuthState(finalState);

              debugPrint(
                'AuthController.login: Login completed successfully for: ${user.email}',
              );
              return Success(user);
            },
            (error) async {
              debugPrint(
                'AuthController.login: Failed to fetch user data: $error',
              );

              // Falhou ao buscar usuário, mas login foi bem-sucedido
              // Mantém estado autenticado mas sem dados do usuário
              final partialState = AuthState(
                status: AuthStatus.authenticated,
                token: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                tokenExpiry: DateTime.now().add(
                  Duration(seconds: tokenResponse.expiresIn),
                ),
              );

              _updateState(partialState);
              await _repository.saveAuthState(partialState);

              debugPrint(
                'AuthController.login: Login successful but failed to get user data: $error',
              );
              return Failure(error);
            },
          );
        },
        (error) async {
          debugPrint('AuthController.login: Login API call failed: $error');
          _updateState(const AuthState(status: AuthStatus.unauthenticated));
          return Failure(error);
        },
      );
    } catch (e) {
      debugPrint('AuthController.login: Exception during login: $e');
      _updateState(const AuthState(status: AuthStatus.unauthenticated));
      return Failure(Exception('Erro interno no login: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza logout com limpeza de cache
  Future<void> logout() async {
    try {
      _setLoading(true);

      debugPrint('Starting logout process');

      // Atualização otimista - limpa estado imediatamente
      _updateState(const AuthState(status: AuthStatus.unauthenticated));

      // Tenta fazer logout no servidor
      await _repository.logout();

      // Limpa cache local
      await _repository.clearAuthCache();

      debugPrint('Logout completed');
    } catch (e) {
      debugPrint('Logout error: $e');
      // Mesmo com erro, mantém estado deslogado
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza dados do usuário atual com cache otimista
  AsyncResult<User> updateCurrentUser(UpdateUserRequest request) async {
    if (!isAuthenticated || currentUser == null) {
      return Failure(Exception('Usuário não autenticado'));
    }

    try {
      _setLoading(true);

      // Cria versão otimista do usuário
      final optimisticUser = currentUser!.copyWith(
        name: request.name ?? currentUser!.name,
        email: request.email ?? currentUser!.email,
        phoneNumber: request.phoneNumber ?? currentUser!.phoneNumber,
      );

      // Atualização otimista
      final optimisticState = _state.copyWith(user: optimisticUser);
      _updateState(optimisticState);

      // Salva no cache
      await _repository.saveAuthState(optimisticState);

      // Faz a requisição real
      final updateResult = await _repository.updateCurrentUser(request);

      return await updateResult.fold(
        (success) async {
          // Busca dados atualizados do servidor
          final userResult = await _repository.getCurrentUser();

          return await userResult.fold(
            (updatedUser) async {
              final finalState = _state.copyWith(user: updatedUser);
              _updateState(finalState);
              await _repository.saveAuthState(finalState);

              debugPrint('User updated successfully');
              return Success(updatedUser);
            },
            (error) async {
              // Falhou ao buscar dados atualizados, mantém versão otimista
              debugPrint(
                'Update successful but failed to refresh user data: $error',
              );
              return Success(optimisticUser);
            },
          );
        },
        (error) async {
          // Reverte para versão original
          _updateState(_state.copyWith(user: currentUser));
          await _repository.saveAuthState(_state);

          debugPrint('User update failed: $error');
          return Failure(error);
        },
      );
    } catch (e) {
      // Reverte para versão original em caso de erro
      _updateState(_state.copyWith(user: currentUser));
      await _repository.saveAuthState(_state);

      debugPrint('User update error: $e');
      return Failure(Exception('Erro ao atualizar usuário: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  /// Cria um novo usuário
  AsyncResult<bool> createUser(CreateUserRequest request) async {
    try {
      _setLoading(true);

      debugPrint('Creating user: ${request.email}');

      return await _repository.createUser(request);
    } catch (e) {
      debugPrint('Create user error: $e');
      return Failure(Exception('Erro ao criar usuário: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém usuário por ID
  AsyncResult<User> getUserById(String id) async {
    return await _repository.getUserById(id);
  }

  /// Obtém todos os usuários
  AsyncResult<List<User>> getAllUsers() async {
    return await _repository.getAllUsers();
  }

  /// Obtém usuários por banco ortopédico
  AsyncResult<List<User>> getUsersByOrthopedicBank(String bankId) async {
    return await _repository.getUsersByOrthopedicBank(bankId);
  }

  /// Deleta usuário
  AsyncResult<bool> deleteUser(String id) async {
    return await _repository.deleteUser(id);
  }

  /// Atualiza dados do usuário atual do servidor
  Future<void> refreshCurrentUser() async {
    if (!isAuthenticated) return;

    await _refreshCurrentUser();
  }

  /// Força atualização do estado
  void forceUpdate() {
    notifyListeners();
    _stateController?.add(_state);
  }

  /// Limpa estado de autenticação
  Future<void> clearAuthState() async {
    await logout();
  }

  // Métodos privados

  void _updateState(AuthState newState) {
    if (_state != newState) {
      _state = newState;
      debugPrint(
        'AuthController._updateState: Auth state updated: ${newState.status}',
      );
      debugPrint(
        'AuthController._updateState: Has token: ${newState.token != null}',
      );
      debugPrint(
        'AuthController._updateState: Has user: ${newState.user != null}',
      );
      notifyListeners();
      _stateController?.add(newState);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      debugPrint('Auth loading state: $loading');
      notifyListeners();
    }
  }

  Future<void> _refreshCurrentUser() async {
    if (!isAuthenticated) return;

    try {
      final userResult = await _repository.getCurrentUser();

      await userResult.fold(
        (user) async {
          final updatedState = _state.copyWith(user: user);
          _updateState(updatedState);
          await _repository.saveAuthState(updatedState);
        },
        (error) {
          debugPrint('Failed to refresh current user: $error');
          // Não atualiza estado em caso de erro, mantém dados em cache
        },
      );
    } catch (e) {
      debugPrint('Error refreshing current user: $e');
    }
  }

  @override
  void dispose() {
    _stateController?.close();
    super.dispose();
  }
}
