import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/orthopedic_banks_models.dart';

/// Serviço de cache para dados de bancos ortopédicos
class OrthopedicBanksCacheService {
  static const String _banksKey = 'orthopedic_banks_list';

  final SharedPreferences _prefs;

  OrthopedicBanksCacheService._(this._prefs);

  /// Factory para criar instância do serviço
  static Future<OrthopedicBanksCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OrthopedicBanksCacheService._(prefs);
  }

  /// Salva o estado dos bancos ortopédicos no cache
  Future<void> saveOrthopedicBanksState(List<OrthopedicBank> state) async {
    try {
      final banksJson = jsonEncode(state.map((bank) => bank.toJson()).toList());
      await _prefs.setString(_banksKey, banksJson);
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error saving state: $e');
    }
  }

  /// Salva o estado completo dos bancos ortopédicos
  Future<void> saveOrthopedicBankState(OrthopedicBank state) async {
    final temp = await loadOrthopedicBanksState();

    temp.add(state);
  }

  /// Atualiza um banco ortopédico no cache
  Future<void> updateOrthopedicBankState(OrthopedicBank bank) async {
    final banks = await loadOrthopedicBanksState();
    final index = banks.indexWhere((b) => b.id == bank.id);
    if (index != -1) {
      banks[index] = bank;
      await saveOrthopedicBanksState(banks);
    } else {
      debugPrint(
        'OrthopedicBanksCacheService: Bank not found for update: ${bank.id}',
      );
    }
  }

  /// Remove um banco ortopédico do cache
  Future<void> removeOrthopedicBankState(String bankId) async {
    final banks = await loadOrthopedicBanksState();
    final updatedBanks = banks.where((b) => b.id != bankId).toList();
    await saveOrthopedicBanksState(updatedBanks);
  }

  /// Carrega o estado dos bancos ortopédicos do cache
  Future<List<OrthopedicBank>> loadOrthopedicBanksState() async {
    try {
      final banksJson = _prefs.getString(_banksKey);

      List<OrthopedicBank> banks = [];

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

      return banks;
    } catch (e) {
      debugPrint('OrthopedicBanksCacheService: Error loading state: $e');
      return [];
    }
  }
}
