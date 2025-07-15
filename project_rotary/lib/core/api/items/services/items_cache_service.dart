import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para items usando SharedPreferences
class ItemsCacheService {
  static const String _itemsByStockPrefix = 'cached_items_stock_';
  static const String _lastUpdateKey = 'items_last_update';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  SharedPreferences? _prefs;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva items de um stock específico no cache
  Future<void> cacheItemsByStock(String stockId, List<Item> items) async {
    if (_prefs == null) return;

    try {
      final itemsJson = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(itemsJson);

      await _prefs!.setString('$_itemsByStockPrefix$stockId', jsonString);
      await _prefs!.setString(
        '${_lastUpdateKey}_stock_$stockId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar items do stock $stockId no cache: $e');
    }
  }

  /// Recupera items de um stock específico do cache
  Future<List<Item>?> getCachedItemsByStock(String stockId) async {
    if (_prefs == null) return null;

    try {
      // Verifica se o cache específico do stock é válido
      final lastUpdateStr = _prefs!.getString(
        '${_lastUpdateKey}_stock_$stockId',
      );
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();

      if (now.difference(lastUpdate) >= _cacheExpiration) return null;

      final jsonString = _prefs!.getString('$_itemsByStockPrefix$stockId');
      if (jsonString == null) return null;

      final itemsJson = jsonDecode(jsonString) as List<dynamic>;
      return itemsJson
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao recuperar items do stock $stockId do cache: $e');
      return null;
    }
  }

  /// Limpa cache de um stock específico
  Future<void> clearStockCache(String stockId) async {
    if (_prefs == null) return;

    try {
      await _prefs!.remove('$_itemsByStockPrefix$stockId');
      await _prefs!.remove('${_lastUpdateKey}_stock_$stockId');
    } catch (e) {
      debugPrint('Erro ao limpar cache do stock $stockId: $e');
    }
  }

  /// Verifica se tem cache válido para um stock específico
  bool hasValidStockCache(String stockId) {
    if (_prefs == null) return false;

    final lastUpdateStr = _prefs!.getString('${_lastUpdateKey}_stock_$stockId');
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();

    return now.difference(lastUpdate) < _cacheExpiration &&
        _prefs!.containsKey('$_itemsByStockPrefix$stockId');
  }

  /// função para a criação de um novo item
  Future<void> createItem(Item item) async {
    if (_prefs == null) return;

    // Busca o cache existente
    final cachedItems = await getCachedItemsByStock(item.stockId);
    if (cachedItems == null) return;
    // Adiciona o novo item ao cache
    cachedItems.add(item);
    // Salva o cache atualizado
    await cacheItemsByStock(item.stockId, cachedItems);
  }

  /// Atualiza cache após criação/atualização de item
  Future<void> updateCacheAfterModification(Item item) async {
    if (_prefs == null) return;

    //Busca o cache existente
    final cachedItems = await getCachedItemsByStock(item.stockId);
    if (cachedItems == null) return;

    // Atualiza ou adiciona o item no cache
    cachedItems.removeWhere((i) => i.id == item.id);
    cachedItems.add(item);

    // Salva o cache atualizado
    await cacheItemsByStock(item.stockId, cachedItems);
  }

  Future<void> removeItemFromCache(String itemId) async {
    if (_prefs == null) return;

    // Busca o cache existente
    final cachedItems = await getCachedItemsByStock(itemId);
    if (cachedItems == null) return;

    // Remove o item do cache
    cachedItems.removeWhere((item) => item.id == itemId);

    // Salva o cache atualizado
    await cacheItemsByStock(itemId, cachedItems);
  }
}
