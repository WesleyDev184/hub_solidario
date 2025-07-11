import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/auth/types/result_types.dart';

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

  // === MÉTODOS DE CONVENIÊNCIA ===

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (_instance == null) {
      throw Exception(
        'OrthopedicBanksService não foi inicializado. Chame OrthopedicBanksService.initialize() primeiro.',
      );
    }
  }

  /// Carrega todos os bancos ortopédicos
  static AsyncResult<List<OrthopedicBank>> getOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadOrthopedicBanks(forceRefresh: forceRefresh);
  }

  /// Busca um banco ortopédico por ID
  static AsyncResult<OrthopedicBank> getOrthopedicBank(String bankId) async {
    await ensureInitialized();
    return _instance!.getOrthopedicBank(bankId);
  }

  /// Cria um novo banco ortopédico
  static AsyncResult<OrthopedicBank> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.createOrthopedicBank(request);
  }

  /// Atualiza um banco ortopédico existente
  static AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateOrthopedicBank(bankId, request);
  }

  /// Deleta um banco ortopédico
  static AsyncResult<void> deleteOrthopedicBank(String bankId) async {
    await ensureInitialized();
    return _instance!.deleteOrthopedicBank(bankId);
  }

  /// Busca bancos por nome ou cidade
  static List<OrthopedicBank> searchBanks(String query) {
    if (_instance == null) {
      return [];
    }
    return _instance!.searchBanks(query);
  }

  /// Obtém banco por ID do estado atual (sincrono)
  static OrthopedicBank? getBankById(String bankId) {
    if (_instance == null) {
      return null;
    }
    return _instance!.getBankById(bankId);
  }

  /// Obtém todos os bancos do estado atual (sincrono)
  static List<OrthopedicBank> get banks {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks;
  }

  /// Verifica se há bancos carregados
  static bool get hasBanks {
    if (_instance == null) {
      return false;
    }
    return _instance!.isNotEmpty;
  }

  /// Obtém o número de bancos carregados
  static int get banksCount {
    if (_instance == null) {
      return 0;
    }
    return _instance!.count;
  }

  /// Verifica se está carregando
  static bool get isLoading {
    if (_instance == null) {
      return false;
    }
    return _instance!.isLoading;
  }

  /// Obtém o estado atual dos bancos
  static OrthopedicBanksState get state {
    if (_instance == null) {
      return const OrthopedicBanksState();
    }
    return _instance!.state;
  }

  /// Stream do estado dos bancos ortopédicos
  static Stream<OrthopedicBanksState> get stateStream {
    if (_instance == null) {
      return const Stream.empty();
    }
    return _instance!.stateStream;
  }

  /// Busca bancos por cidade
  static List<OrthopedicBank> getBanksByCity(String city) {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks
        .where((bank) => bank.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  /// Obtém todas as cidades únicas dos bancos
  static List<String> getCities() {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks.map((bank) => bank.city).toSet().toList()..sort();
  }

  /// Obtém estatísticas dos bancos por cidade
  static Map<String, int> getBankStatisticsByCity() {
    if (_instance == null) {
      return {};
    }

    final statistics = <String, int>{};
    for (final bank in _instance!.banks) {
      statistics[bank.city] = (statistics[bank.city] ?? 0) + 1;
    }
    return statistics;
  }

  /// Verifica se um banco existe
  static bool bankExists(String bankId) {
    if (_instance == null) {
      return false;
    }
    return _instance!.getBankById(bankId) != null;
  }

  /// Limpa cache de bancos
  static Future<void> clearCache() async {
    await ensureInitialized();
    return _instance!.clearCache();
  }

  /// Força atualização do cache
  static Future<void> refreshCache() async {
    await ensureInitialized();
    return _instance!.refresh();
  }

  /// Busca bancos criados após uma data específica
  static List<OrthopedicBank> getBanksCreatedAfter(DateTime date) {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks
        .where((bank) => bank.createdAt.isAfter(date))
        .toList();
  }

  /// Busca bancos criados antes de uma data específica
  static List<OrthopedicBank> getBanksCreatedBefore(DateTime date) {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks
        .where((bank) => bank.createdAt.isBefore(date))
        .toList();
  }

  /// Busca bancos criados em um período específico
  static List<OrthopedicBank> getBanksCreatedBetween(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (_instance == null) {
      return [];
    }
    return _instance!.banks
        .where(
          (bank) =>
              bank.createdAt.isAfter(startDate) &&
              bank.createdAt.isBefore(endDate),
        )
        .toList();
  }

  /// Obtém o banco mais recente
  static OrthopedicBank? getLatestBank() {
    if (_instance == null || _instance!.banks.isEmpty) {
      return null;
    }
    return _instance!.banks.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
  }

  /// Obtém o banco mais antigo
  static OrthopedicBank? getOldestBank() {
    if (_instance == null || _instance!.banks.isEmpty) {
      return null;
    }
    return _instance!.banks.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
  }

  /// Obtém bancos ordenados por nome
  static List<OrthopedicBank> getBanksSortedByName({bool ascending = true}) {
    if (_instance == null) {
      return [];
    }
    final banks = List<OrthopedicBank>.from(_instance!.banks);
    banks.sort(
      (a, b) => ascending ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
    );
    return banks;
  }

  /// Obtém bancos ordenados por cidade
  static List<OrthopedicBank> getBanksSortedByCity({bool ascending = true}) {
    if (_instance == null) {
      return [];
    }
    final banks = List<OrthopedicBank>.from(_instance!.banks);
    banks.sort(
      (a, b) => ascending ? a.city.compareTo(b.city) : b.city.compareTo(a.city),
    );
    return banks;
  }

  /// Obtém bancos ordenados por data de criação
  static List<OrthopedicBank> getBanksSortedByCreationDate({
    bool ascending = true,
  }) {
    if (_instance == null) {
      return [];
    }
    final banks = List<OrthopedicBank>.from(_instance!.banks);
    banks.sort(
      (a, b) =>
          ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt),
    );
    return banks;
  }
}
