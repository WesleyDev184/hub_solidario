import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/orthopedic_banks/models/orthopedic_banks_models.dart';
import 'package:result_dart/result_dart.dart';

import 'auth.dart';

/// Serviço de configuração e inicialização do módulo de autenticação
class AuthService {
  static AuthController? _instance;
  static AuthRepository? _repository;
  static AuthCacheService? _cacheService;
  static Completer<AuthController>? _initializationCompleter;

  /// Inicializa o serviço de autenticação
  static Future<AuthController> initialize({
    required ApiClient apiClient,
    String? apiKey,
  }) async {
    try {
      debugPrint('AuthService.initialize: Starting initialization');

      // Se já está inicializando, espera a inicialização atual
      if (_initializationCompleter != null) {
        debugPrint(
          'AuthService.initialize: Already initializing, waiting for completion',
        );
        return await _initializationCompleter!.future;
      }

      // Se já foi inicializado, retorna a instância existente
      if (_instance != null) {
        debugPrint(
          'AuthService.initialize: Already initialized, returning existing instance',
        );
        return _instance!;
      }

      // Cria um completer para controlar a inicialização
      _initializationCompleter = Completer<AuthController>();

      try {
        // Configura API Key se fornecida
        if (apiKey != null) {
          debugPrint('AuthService.initialize: Setting API key');
          apiClient.setApiKey(apiKey);
        }

        // Cria cache service
        debugPrint('AuthService.initialize: Creating cache service');
        _cacheService = await AuthCacheService.create();

        // Cria repository
        debugPrint('AuthService.initialize: Creating repository');
        _repository = AuthRepository(
          apiClient: apiClient,
          cacheService: _cacheService!,
        );

        // Cria controller
        debugPrint('AuthService.initialize: Creating controller');
        _instance = AuthController(repository: _repository!);

        // Configura callback de logout automático no ApiClient
        debugPrint('AuthService.initialize: Setting unauthorized callback');
        apiClient.setOnUnauthorizedCallback(() {
          debugPrint('ApiClient: Unauthorized callback triggered');
          _instance?.logout();
        });

        // Configura sincronização automática de token ANTES da inicialização
        debugPrint('AuthService.initialize: Setting up token sync listener');
        _instance!.addListener(() {
          if (_instance!.isAuthenticated && _instance!.accessToken != null) {
            debugPrint('AuthController: Setting access token in ApiClient');
            apiClient.setAccessToken(_instance!.accessToken!);
          } else {
            debugPrint('AuthController: Clearing access token from ApiClient');
            apiClient.clearAccessToken();
          }
        });

        // Inicializa o controller (carrega estado do cache)
        debugPrint('AuthService.initialize: Initializing controller');
        await _instance!.initialize();

        // Configura token no ApiClient se já estiver autenticado (backup)
        if (_instance!.isAuthenticated && _instance!.accessToken != null) {
          debugPrint(
            'AuthService.initialize: Setting access token in ApiClient (backup)',
          );
          apiClient.setAccessToken(_instance!.accessToken!);
        }

        debugPrint(
          'AuthService.initialize: Initialization completed successfully',
        );

        // Completa a inicialização
        _initializationCompleter!.complete(_instance!);
        return _instance!;
      } catch (e) {
        // Em caso de erro, completa com erro
        _initializationCompleter!.completeError(e);
        rethrow;
      } finally {
        // Limpa o completer
        _initializationCompleter = null;
      }
    } catch (e) {
      debugPrint('AuthService.initialize: Error during initialization: $e');
      rethrow;
    }
  }

  /// Obtém a instância atual do AuthController
  static AuthController? get instance => _instance;

  /// Obtém a instância atual do AuthRepository
  static AuthRepository? get repository => _repository;

  /// Obtém a instância atual do AuthCacheService
  static AuthCacheService? get cacheService => _cacheService;

  /// Verifica se o serviço foi inicializado
  static bool get isInitialized => _instance != null;

  /// Força reinicialização do serviço
  static Future<void> reset() async {
    _instance?.dispose();
    _instance = null;
    _repository = null;
    _cacheService = null;
  }

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (!isInitialized) {
      throw Exception(
        'AuthService não foi inicializado. Chame AuthService.initialize() primeiro.',
      );
    }
  }

  // === MÉTODOS DE CONVENIÊNCIA ===

  /// Realiza login
  static AsyncResult<User> login(String email, String password) async {
    await ensureInitialized();
    return _instance!.login(email, password);
  }

  /// Realiza logout
  static Future<void> logout() async {
    await ensureInitialized();
    return _instance!.logout();
  }

  /// Obtém o usuário atual
  static User? get currentUser {
    if (!isInitialized) return null;
    return _instance!.currentUser;
  }

  /// Obtém o token de acesso atual
  static String? get accessToken {
    if (!isInitialized) return null;
    return _instance!.accessToken;
  }

  /// Verifica se está autenticado
  static bool get isAuthenticated {
    if (!isInitialized) return false;
    return _instance!.isAuthenticated;
  }

  /// Verifica se está desautenticado
  static bool get isUnauthenticated {
    if (!isInitialized) return true;
    return _instance!.isUnauthenticated;
  }

  /// Verifica se está carregando
  static bool get isLoading {
    if (!isInitialized) return false;
    return _instance!.isLoading;
  }

  /// Obtém o estado atual de autenticação
  static AuthState get state {
    if (!isInitialized) return const AuthState(status: AuthStatus.unknown);
    return _instance!.state;
  }

  /// Stream do estado de autenticação
  static Stream<AuthState> get stateStream {
    if (!isInitialized) return const Stream.empty();
    return _instance!.stateStream;
  }

  /// Atualiza dados do usuário atual
  static AsyncResult<User> updateCurrentUser(UpdateUserRequest request) async {
    await ensureInitialized();
    return _instance!.updateCurrentUser(request);
  }

  /// Cria um novo usuário
  static AsyncResult<bool> createUser(CreateUserRequest request) async {
    await ensureInitialized();
    return _instance!.createUser(request);
  }

  /// Obtém usuário por ID
  static AsyncResult<User> getUserById(String id) async {
    await ensureInitialized();
    return _instance!.getUserById(id);
  }

  /// Obtém todos os usuários por banco ortopédico
  static AsyncResult<List<User>> getAllUsers(String bankId) async {
    await ensureInitialized();
    return _instance!.getAllUsers(bankId);
  }

  /// Obtém todos os usuários forçando refresh do servidor
  static AsyncResult<List<User>> refreshAllUsers() async {
    await ensureInitialized();
    return _instance!.refreshAllUsers();
  }

  /// Deleta usuário
  static AsyncResult<bool> deleteUser(String id) async {
    await ensureInitialized();
    return _instance!.deleteUser(id);
  }

  /// Atualiza dados do usuário atual do servidor
  static Future<void> refreshCurrentUser() async {
    await ensureInitialized();
    return _instance!.refreshCurrentUser();
  }

  /// Força atualização do estado
  static void forceUpdate() {
    if (!isInitialized) return;
    _instance!.forceUpdate();
  }

  /// Limpa estado de autenticação
  static Future<void> clearAuthState() async {
    await ensureInitialized();
    return _instance!.clearAuthState();
  }

  /// Verifica se o token está expirado
  static bool get isTokenExpired {
    if (!isInitialized) return true;
    return _instance!.state.isTokenExpired;
  }

  /// Obtém data de expiração do token
  static DateTime? get tokenExpiry {
    if (!isInitialized) return null;
    return _instance!.state.tokenExpiry;
  }

  /// Obtém refresh token
  static String? get refreshToken {
    if (!isInitialized) return null;
    return _instance!.state.refreshToken;
  }

  /// Verifica se o usuário está logado e o token é válido
  static bool get isValidAuthentication {
    if (!isInitialized) return false;
    return _instance!.isAuthenticated && !_instance!.state.isTokenExpired;
  }

  /// Obtém informações do banco ortopédico do usuário atual
  static OrthopedicBank? get currentUserOrthopedicBank {
    if (!isInitialized || _instance!.currentUser == null) return null;
    return _instance!.currentUser!.orthopedicBank;
  }

  /// Verifica se o usuário atual tem banco ortopédico associado
  static bool get hasOrthopedicBank {
    return currentUserOrthopedicBank != null;
  }

  /// Obtém o ID do banco ortopédico do usuário atual
  static String? get currentUserOrthopedicBankId {
    return currentUserOrthopedicBank?.id;
  }

  /// Obtém o nome do usuário atual
  static String? get currentUserName {
    return currentUser?.name;
  }

  /// Obtém o email do usuário atual
  static String? get currentUserEmail {
    return currentUser?.email;
  }

  /// Obtém o telefone do usuário atual
  static String? get currentUserPhoneNumber {
    return currentUser?.phoneNumber;
  }

  /// Obtém o ID do usuário atual
  static String? get currentUserId {
    return currentUser?.id;
  }

  /// Obtém a data de criação do usuário atual
  static DateTime? get currentUserCreatedAt {
    return currentUser?.createdAt;
  }
}
