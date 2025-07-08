import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/orthopedic_banks_models.dart';

/// Serviço de cache para dados de bancos ortopédicos
class OrthopedicBanksCacheService {
  static const String _banksKey = 'orthopedic_banks_list';
  static const String _lastUpdatedKey = 'orthopedic_banks_last_updated';

  final SharedPreferences _prefs;

  OrthopedicBanksCacheService._(this._prefs);

  /// Factory para criar instância do serviço
  static Future<OrthopedicBanksCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OrthopedicBanksCacheService._(prefs);
  }

  /// Salva o estado completo dos bancos ortopédicos
  Future<void> saveOrthopedicBanksState(OrthopedicBanksState state) async {
    try {
      if (state.banks.isNotEmpty) {
        final banksJson = state.banks.map((bank) => bank.toJson()).toList();
        await _prefs.setString(_banksKey, jsonEncode(banksJson));
      } else {
        await _prefs.remove(_banksKey);
      }

      if (state.lastUpdated != null) {
        await _prefs.setString(
          _lastUpdatedKey,
          state.lastUpdated!.toIso8601String(),
        );
      } else {
        await _prefs.remove(_lastUpdatedKey);
      }

      debugPrint(
        'OrthopedicBanksCacheService: State saved - ${state.count} banks',
      );
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error saving state: $e');
    }
  }

  /// Carrega o estado dos bancos ortopédicos do cache
  Future<OrthopedicBanksState> loadOrthopedicBanksState() async {
    try {
      final banksJson = _prefs.getString(_banksKey);
      final lastUpdatedString = _prefs.getString(_lastUpdatedKey);

      List<OrthopedicBank> banks = [];
      DateTime? lastUpdated;

      if (banksJson != null) {
        final banksList = jsonDecode(banksJson) as List;
        banks =
            banksList
                .map(
                  (json) =>
                      OrthopedicBank.fromJson(json as Map<String, dynamic>),
                )
                .toList();
      }

      if (lastUpdatedString != null) {
        lastUpdated = DateTime.parse(lastUpdatedString);
      }

      debugPrint(
        'OrthopedicBanksCacheService: State loaded - ${banks.length} banks, '
        'last updated: $lastUpdated',
      );

      return OrthopedicBanksState(banks: banks, lastUpdated: lastUpdated);
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error loading state: $e');
      return const OrthopedicBanksState();
    }
  }

  /// Salva um banco ortopédico específico no cache
  Future<void> saveOrthopedicBank(OrthopedicBank bank) async {
    try {
      final currentState = await loadOrthopedicBanksState();
      final updatedBanks = List<OrthopedicBank>.from(currentState.banks);

      // Remove banco existente se já estiver na lista
      updatedBanks.removeWhere((b) => b.id == bank.id);
      // Adiciona o banco atualizado
      updatedBanks.add(bank);

      final newState = OrthopedicBanksState(
        banks: updatedBanks,
        lastUpdated: DateTime.now(),
      );

      await saveOrthopedicBanksState(newState);
      debugPrint('OrthopedicBanksCacheService: Bank saved: ${bank.name}');
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error saving bank: $e');
    }
  }

  /// Remove um banco ortopédico específico do cache
  Future<void> removeOrthopedicBank(String bankId) async {
    try {
      final currentState = await loadOrthopedicBanksState();
      final updatedBanks =
          currentState.banks.where((bank) => bank.id != bankId).toList();

      final newState = OrthopedicBanksState(
        banks: updatedBanks,
        lastUpdated: DateTime.now(),
      );

      await saveOrthopedicBanksState(newState);
      debugPrint('OrthopedicBanksCacheService: Bank removed: $bankId');
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error removing bank: $e');
    }
  }

  /// Busca um banco ortopédico específico no cache
  Future<OrthopedicBank?> getOrthopedicBank(String bankId) async {
    try {
      final state = await loadOrthopedicBanksState();
      return state.banks.firstWhere(
        (bank) => bank.id == bankId,
        orElse: () => throw StateError('Bank not found'),
      );
    } catch (e) {
      debugPrint(
        'OrthopedicBanksCacheService: Bank not found in cache: $bankId',
      );
      return null;
    }
  }

  /// Limpa todo o cache de bancos ortopédicos
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_banksKey);
      await _prefs.remove(_lastUpdatedKey);
      debugPrint('OrthopedicBanksCacheService: Cache cleared');
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error clearing cache: $e');
    }
  }

  /// Verifica se o cache expirou (baseado em tempo)
  Future<bool> isCacheExpired({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final state = await loadOrthopedicBanksState();
      if (state.lastUpdated == null) return true;

      final now = DateTime.now();
      final difference = now.difference(state.lastUpdated!);

      return difference > maxAge;
    } catch (e) {
      debugPrint(
        'OrthopedicBanksCacheService: Error checking cache expiry: $e',
      );
      return true;
    }
  }
}
