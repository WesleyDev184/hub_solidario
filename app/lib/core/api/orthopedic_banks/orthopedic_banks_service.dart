import 'dart:async';

import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/auth/types/result_types.dart';

import 'orthopedic_banks.dart';

/// Serviço de configuração e inicialização do módulo de bancos ortopédicos
class OrthopedicBanksService {
  static OrthopedicBanksController? _instance;
  static OrthopedicBanksRepository? _repository;
  static OrthopedicBanksCacheService? _cacheService;

  /// Inicializa o serviço de bancos ortopédicos
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_instance != null) return;
    _cacheService = await OrthopedicBanksCacheService.create();
    _repository = OrthopedicBanksRepository(
      apiClient: apiClient,
      cacheService: _cacheService!,
    );
    _instance = OrthopedicBanksController(_repository!, _cacheService!);
  }

  static OrthopedicBanksController? get instance => _instance;
  static bool get isInitialized => _instance != null;

  static void reset() {
    _instance = null;
    _repository = null;
    _cacheService = null;
  }

  static Future<void> ensureInitialized() async {
    if (_instance == null) {
      throw Exception(
        'OrthopedicBanksService não foi inicializado. Chame OrthopedicBanksService.initialize() primeiro.',
      );
    }
  }

  static AsyncResult<List<OrthopedicBank>> getOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadOrthopedicBanks(forceRefresh: forceRefresh);
  }

  // O controller não possui getOrthopedicBank, apenas loadOrthopedicBanks
  // Para buscar por ID, é necessário buscar todos e filtrar
  static Future<OrthopedicBank?> getOrthopedicBank(String bankId) async {
    await ensureInitialized();
    final result = await _instance!.loadOrthopedicBanks();
    return result.fold((banks) {
      final found = banks.where((b) => b.id == bankId);
      return found.isNotEmpty ? found.first : null;
    }, (_) => null);
  }

  static AsyncResult<String> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.createOrthopedicBank(request);
  }

  static AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateOrthopedicBank(bankId, request);
  }

  static AsyncResult<bool> deleteOrthopedicBank(String bankId) async {
    await ensureInitialized();
    return _instance!.deleteOrthopedicBank(bankId);
  }

  // O controller não possui searchBanks, mas pode filtrar manualmente
  static Future<List<OrthopedicBank>> searchBanks(String query) async {
    await ensureInitialized();
    final result = await _instance!.loadOrthopedicBanks();
    return result.fold((banks) {
      if (query.isEmpty) return banks;
      final lowerQuery = query.toLowerCase();
      return banks
          .where(
            (bank) =>
                bank.name.toLowerCase().contains(lowerQuery) ||
                bank.city.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }, (_) => []);
  }

  static Future<OrthopedicBank?> getBankById(String bankId) async {
    return getOrthopedicBank(bankId);
  }

  static Future<List<OrthopedicBank>> get banks async {
    await ensureInitialized();
    final result = await _instance!.loadOrthopedicBanks();
    return result.fold((banks) => banks, (_) => []);
  }

  static Future<bool> get hasBanks async {
    final list = await banks;
    return list.isNotEmpty;
  }

  static Future<int> get banksCount async {
    final list = await banks;
    return list.length;
  }

  static bool get isLoading {
    if (_instance == null) return false;
    return _instance!.isLoading;
  }
}
