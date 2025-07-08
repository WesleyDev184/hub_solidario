import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:project_rotary/core/api/api_client.dart';

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
}
