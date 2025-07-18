import 'package:app/core/api/api_client.dart';
import 'package:get/get.dart';

import 'auth.dart'; // aqui você importa AuthController, AuthRepository, AuthCacheService

class AuthService {
  static AuthService? _instance;

  late final AuthController authController;
  final ApiClient apiClient;

  AuthService._internal(this.apiClient);

  static AuthService get instance {
    if (_instance == null) {
      throw Exception('AuthService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = AuthService._internal(apiClient);

    final cacheService = await AuthCacheService.create();
    final repository = AuthRepository(apiClient: apiClient);

    // Cria o controller com as dependências
    service.authController = AuthController(
      repository: repository,
      cacheService: cacheService,
    );

    // Registra no GetX para acesso global e reatividade
    Get.put<AuthController>(service.authController, permanent: true);

    _instance = service;
  }
}
