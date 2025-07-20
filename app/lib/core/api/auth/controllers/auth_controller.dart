import 'package:app/app.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';
import 'package:routefly/routefly.dart';

import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_cache_service.dart';

class AuthController extends GetxController {
  final AuthRepository repository;
  final AuthCacheService cacheService;

  // Estados reativos
  final Rx<AuthState> _state = const AuthState(status: AuthStatus.unknown).obs;
  Rx<AuthState> get stateRx => _state;
  final RxBool _isLoading = false.obs;

  AuthState get state => _state.value;
  bool get isAuthenticated => _state.value.isAuthenticated;
  bool get isUnauthenticated => _state.value.isUnauthenticated;
  bool get isLoading => _isLoading.value;
  User? get currentUser => _state.value.user;
  String? get getOrthopedicBankId => _state.value.user?.orthopedicBank?.id;
  String? get accessToken => _state.value.token;

  @override
  void onInit() {
    super.onInit();
    getAuthState();
  }

  AuthController({required this.repository, required this.cacheService});

  AsyncResult<AuthState> getAuthState() async {
    try {
      final cachedState = await cacheService.loadAuthState();
      if (cachedState.status == AuthStatus.unauthenticated ||
          cachedState.status == AuthStatus.unknown) {
        // limpa o cache se não autenticado
        await cacheService.clearAuthData();
        _state.value = const AuthState(status: AuthStatus.unauthenticated);
        return Failure(
          Exception('Usuário não autenticado ou estado desconhecido'),
        );
      }
      _state.value = cachedState;
      repository.configureApiClientToken(cachedState.token);
      return Success(cachedState);
    } catch (e) {
      return Failure(
        Exception('Erro ao obter estado de autenticação: ${e.toString()}'),
      );
    }
  }

  AsyncResult<User> login(String email, String password) async {
    _setLoading(true);
    try {
      final loginResult = await repository.login(email, password);

      return await loginResult.fold(
        (tokenResponse) async {
          await cacheService.saveTokenData(tokenResponse);
          repository.configureApiClientToken(tokenResponse.accessToken);

          final userResult = await repository.getCurrentUser();
          return await userResult.fold(
            (user) async {
              final finalState = _state.value.copyWith(
                status: AuthStatus.authenticated,
                token: tokenResponse.accessToken,
                refreshToken: tokenResponse.refreshToken,
                tokenExpiry: DateTime.now().add(
                  Duration(seconds: tokenResponse.expiresIn),
                ),
                user: user,
              );
              _state.value = finalState;
              await cacheService.saveAuthState(finalState);
              await cacheService.addUserToAllUsers(user);
              return Success(user);
            },
            (error) async {
              // Não autentica se não conseguir recuperar usuário
              _state.value = const AuthState(
                status: AuthStatus.unauthenticated,
              );
              await cacheService.clearAuthData();
              return Failure(error);
            },
          );
        },
        (error) async {
          _state.value = const AuthState(status: AuthStatus.unauthenticated);
          await cacheService.clearAuthData();
          return Failure(error);
        },
      );
    } catch (e) {
      _state.value = const AuthState(status: AuthStatus.unauthenticated);
      await cacheService.clearAuthData();
      return Failure(Exception('Erro interno: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  AsyncResult<bool> signup(CreateUserRequest request) async {
    _setLoading(true);
    try {
      final result = await repository.createUser(request);

      return result.fold(
        (user) async {
          return Success(user);
        },
        (error) async {
          return Failure(error);
        },
      );
    } catch (e) {
      return Failure(Exception('Erro interno: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza usuário atual (com cache otimista)
  AsyncResult<User> updateCurrentUser(UpdateUserRequest request) async {
    if (!isAuthenticated || currentUser == null) {
      return Failure(Exception('Usuário não autenticado'));
    }

    try {
      _setLoading(true);

      final optimisticUser = currentUser!.copyWith(
        name: request.name ?? currentUser!.name,
        email: request.email ?? currentUser!.email,
        phoneNumber: request.phoneNumber ?? currentUser!.phoneNumber,
      );

      final optimisticState = state.copyWith(user: optimisticUser);
      _updateState(optimisticState);
      await cacheService.saveUser(optimisticUser);

      final updateResult = await repository.updateCurrentUser(request);

      return await updateResult.fold(
        (success) async {
          final userResult = await repository.getCurrentUser();

          return await userResult.fold(
            (updatedUser) async {
              final finalState = state.copyWith(user: updatedUser);
              _updateState(finalState);
              await cacheService.saveUser(updatedUser);
              await cacheService.addUserToAllUsers(updatedUser);
              return Success(updatedUser);
            },
            (error) async {
              // Caso erro ao obter user após update, mantém otimista
              return Success(optimisticUser);
            },
          );
        },
        (error) async {
          // Reverte estado para user anterior
          _updateState(state.copyWith(user: currentUser));
          await cacheService.saveUser(currentUser!);
          return Failure(error);
        },
      );
    } catch (e) {
      _updateState(state.copyWith(user: currentUser));
      await cacheService.saveUser(currentUser!);
      return Failure(Exception('Erro ao atualizar usuário: ${e.toString()}'));
    } finally {
      _setLoading(false);
    }
  }

  /// Busca usuário por ID (prioriza cache)
  AsyncResult<User> getUserById(String id) async {
    try {
      final cachedUser = await cacheService.findUserInAllUsers(id);
      if (cachedUser != null) return Success(cachedUser);

      final result = await repository.getUserById(id);
      return await result.fold((user) async {
        await cacheService.addUserToAllUsers(user);
        return Success(user);
      }, (error) async => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao obter usuário: ${e.toString()}'));
    }
  }

  /// Busca todos os usuários do banco ortopédico (prioriza cache)
  AsyncResult<List<User>> getAllUsers(String bankId) async {
    try {
      final hasCache = await cacheService.hasAllUsersCache();
      if (hasCache) {
        final cachedUsers = await cacheService.loadAllUsers();
        if (cachedUsers.isNotEmpty) return Success(cachedUsers);
      }

      final allUsers = await repository.getUsersByOrthopedicBank(bankId);
      return await allUsers.fold((users) async {
        await cacheService.saveAllUsers(users);
        return Success(users);
      }, (error) async => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao obter usuários: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      _state.value = const AuthState(status: AuthStatus.unauthenticated);
      await cacheService.clearAuthData();
      await repository.logout();
    } catch (e) {
      print("Erro no logout: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Deleta usuário e atualiza cache
  AsyncResult<bool> deleteUser(String id) async {
    try {
      final result = await repository.deleteUser(id);
      return await result.fold((success) async {
        if (success) await cacheService.removeUserFromAllUsers(id);
        return Success(success);
      }, (error) async => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar usuário: ${e.toString()}'));
    }
  }

  @override
  void onClose() {
    // Qualquer limpeza aqui se precisar
    super.onClose();
  }

  void _updateState(AuthState newState) {
    if (_state.value != newState) {
      _state.value = newState;
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading.value != loading) {
      _isLoading.value = loading;
    }
  }

  Future<void> checkUserPermissions(String currentUri, bool execLogout) async {
    final isAuthPage = currentUri.startsWith("/auth");
    final preventLoop =
        isAuthPage || currentUri.compareTo(routePaths.path) == 0;
    final validToken = await cacheService.hasValidToken();

    if (!isAuthenticated && !isAuthPage) {
      Routefly.pushNavigate(routePaths.auth.signin);
      if (execLogout) {
        await logout();
      }
    }

    if (isAuthenticated && validToken && preventLoop) {
      Routefly.pushNavigate(routePaths.ptd.stocks.path);
    }

    if (isAuthenticated && !validToken) {
      if (execLogout) {
        await logout();
      }
      Routefly.pushNavigate(routePaths.auth.signin);
    }
  }
}
