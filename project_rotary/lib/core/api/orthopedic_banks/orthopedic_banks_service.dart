import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:project_rotary/core/api/api_client.dart';

import 'orthopedic_banks.dart';

/// Serviço de configuração e inicialização do módulo de bancos ortopédicos
class OrthopedicBanksService {
  static OrthopedicBanksController? _instance;
  static OrthopedicBanksRepository? _repository;
  static OrthopedicBanksCacheService? _cacheService;
  static Completer<OrthopedicBanksController>? _initializationCompleter;

  /// Inicializa o serviço de bancos ortopédicos
  static Future<OrthopedicBanksController> initialize({
    required ApiClient apiClient,
  }) async {
    try {
      debugPrint('OrthopedicBanksService.initialize: Starting initialization');

      // Se já está inicializando, espera a inicialização atual
      if (_initializationCompleter != null) {
        debugPrint(
          'OrthopedicBanksService.initialize: Already initializing, waiting for completion',
        );
        return await _initializationCompleter!.future;
      }

      // Se já foi inicializado, retorna a instância existente
      if (_instance != null) {
        debugPrint(
          'OrthopedicBanksService.initialize: Already initialized, returning existing instance',
        );
        return _instance!;
      }

      // Cria um completer para controlar a inicialização
      _initializationCompleter = Completer<OrthopedicBanksController>();

      try {
        // Cria cache service
        debugPrint('OrthopedicBanksService.initialize: Creating cache service');
        _cacheService = await OrthopedicBanksCacheService.create();

        // Cria repository
        debugPrint('OrthopedicBanksService.initialize: Creating repository');
        _repository = OrthopedicBanksRepository(
          apiClient: apiClient,
          cacheService: _cacheService!,
        );

        // Cria controller
        debugPrint('OrthopedicBanksService.initialize: Creating controller');
        _instance = OrthopedicBanksController(repository: _repository!);

        // Inicializa o controller (carrega estado do cache)
        debugPrint(
          'OrthopedicBanksService.initialize: Initializing controller',
        );
        await _instance!.initialize();

        debugPrint(
          'OrthopedicBanksService.initialize: Initialization completed successfully',
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
      debugPrint(
        'OrthopedicBanksService.initialize: Error during initialization: $e',
      );
      rethrow;
    }
  }

  /// Obtém a instância atual do OrthopedicBanksController
  static OrthopedicBanksController? get instance => _instance;

  /// Obtém a instância atual do OrthopedicBanksRepository
  static OrthopedicBanksRepository? get repository => _repository;

  /// Obtém a instância atual do OrthopedicBanksCacheService
  static OrthopedicBanksCacheService? get cacheService => _cacheService;

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
