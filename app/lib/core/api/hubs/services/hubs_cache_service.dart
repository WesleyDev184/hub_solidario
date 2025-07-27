import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/hubs_models.dart';

/// Serviço de cache para dados de hubs
class HubsCacheService {
  static const String _hubsKey = 'hubs_list';

  final SharedPreferences _prefs;

  HubsCacheService._(this._prefs);

  /// Factory para criar instância do serviço
  static Future<HubsCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HubsCacheService._(prefs);
  }

  /// Salva o estado dos bancos ortopédicos no cache
  Future<void> saveHubsState(List<Hub> state) async {
    try {
      final banksJson = jsonEncode(state.map((bank) => bank.toJson()).toList());
      await _prefs.setString(_hubsKey, banksJson);
    } catch (e) {
      debugPrint('HubsCacheService: Error saving state: $e');
    }
  }

  /// Salva o estado completo dos hubs
  Future<void> saveHubState(Hub state) async {
    final temp = await loadHubsState();

    temp.add(state);
  }

  /// Atualiza um hub no cache
  Future<void> updateHubState(Hub hub) async {
    final hubs = await loadHubsState();
    final index = hubs.indexWhere((b) => b.id == hub.id);
    if (index != -1) {
      hubs[index] = hub;
      await saveHubsState(hubs);
    } else {
      debugPrint('HubsCacheService: Hub not found for update: ${hub.id}');
    }
  }

  /// Remove um hub do cache
  Future<void> removeHubState(String hubId) async {
    final hubs = await loadHubsState();
    final updatedHubs = hubs.where((b) => b.id != hubId).toList();
    await saveHubsState(updatedHubs);
  }

  /// Carrega o estado dos bancos ortopédicos do cache
  Future<List<Hub>> loadHubsState() async {
    try {
      final hubsJson = _prefs.getString(_hubsKey);

      List<Hub> hubs = [];

      if (hubsJson != null) {
        final hubsList = jsonDecode(hubsJson) as List;
        hubs = hubsList
            .map((json) => Hub.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return hubs;
    } catch (e) {
      debugPrint('HubsCacheService: Error loading state: $e');
      return [];
    }
  }
}
