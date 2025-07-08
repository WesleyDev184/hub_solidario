import 'package:project_rotary/core/api/api_client.dart';

import 'auth.dart';

/// Serviço de configuração e inicialização do módulo de autenticação
class AuthService {
  static AuthController? _instance;
  static AuthRepository? _repository;
  static AuthCacheService? _cacheService;

  /// Inicializa o serviço de autenticação
  static Future<AuthController> initialize({
    required ApiClient apiClient,
    String? apiKey,
  }) async {
    if (_instance != null) {
      return _instance!;
    }

    // Configura API Key se fornecida
    if (apiKey != null) {
      apiClient.setApiKey(apiKey);
    }

    // Cria cache service
    _cacheService = await AuthCacheService.create();

    // Cria repository
    _repository = AuthRepository(
      apiClient: apiClient,
      cacheService: _cacheService!,
    );

    // Cria controller
    _instance = AuthController(repository: _repository!);

    // Configura callback de logout automático no ApiClient
    apiClient.setOnUnauthorizedCallback(() {
      _instance?.logout();
    });

    // Inicializa o controller (carrega estado do cache)
    await _instance!.initialize();

    // Configura token no ApiClient se já estiver autenticado
    if (_instance!.isAuthenticated && _instance!.accessToken != null) {
      apiClient.setAccessToken(_instance!.accessToken!);
    }

    // Configura sincronização automática de token
    _instance!.addListener(() {
      if (_instance!.isAuthenticated && _instance!.accessToken != null) {
        apiClient.setAccessToken(_instance!.accessToken!);
      } else {
        apiClient.clearAccessToken();
      }
    });

    return _instance!;
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
