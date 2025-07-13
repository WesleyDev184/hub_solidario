import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para items usando SharedPreferences
class ItemsCacheService {
  static const String _itemsKey = 'cached_items';
  static const String _itemsByStockPrefix = 'cached_items_stock_';
  static const String _lastUpdateKey = 'items_last_update';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  SharedPreferences? _prefs;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Verifica se o cache é válido
  bool _isCacheValid() {
    if (_prefs == null) return false;

    final lastUpdateStr = _prefs!.getString(_lastUpdateKey);
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();

    return now.difference(lastUpdate) < _cacheExpiration;
  }

  /// Salva a lista de items no cache
  Future<void> cacheItems(List<Item> items) async {
    if (_prefs == null) return;

    try {
      final itemsJson = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(itemsJson);

      await _prefs!.setString(_itemsKey, jsonString);
      await _prefs!.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erro ao salvar items no cache: $e');
    }
  }

  /// Recupera a lista de items do cache
  Future<List<Item>?> getCachedItems() async {
    if (_prefs == null || !_isCacheValid()) return null;

    try {
      final jsonString = _prefs!.getString(_itemsKey);
      if (jsonString == null) return null;

      final itemsJson = jsonDecode(jsonString) as List<dynamic>;
      return itemsJson
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao recuperar items do cache: $e');
      return null;
    }
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

  /// Salva um item individual no cache
  Future<void> cacheItem(Item item) async {
    if (_prefs == null) return;

    try {
      final key = 'cached_item_${item.id}';
      final jsonString = jsonEncode(item.toJson());

      await _prefs!.setString(key, jsonString);
      await _prefs!.setString(
        '${key}_update',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar item ${item.id} no cache: $e');
    }
  }

  /// Recupera um item individual do cache
  Future<Item?> getCachedItem(String itemId) async {
    if (_prefs == null) return null;

    try {
      final key = 'cached_item_$itemId';

      // Verifica se o cache é válido
      final lastUpdateStr = _prefs!.getString('${key}_update');
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();

      if (now.difference(lastUpdate) >= _cacheExpiration) return null;

      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return null;

      final itemJson = jsonDecode(jsonString) as Map<String, dynamic>;
      return Item.fromJson(itemJson);
    } catch (e) {
      debugPrint('Erro ao recuperar item $itemId do cache: $e');
      return null;
    }
  }

  /// Remove um item específico do cache
  Future<void> removeItemFromCache(String itemId) async {
    if (_prefs == null) return;

    try {
      final key = 'cached_item_$itemId';
      await _prefs!.remove(key);
      await _prefs!.remove('${key}_update');
    } catch (e) {
      debugPrint('Erro ao remover item $itemId do cache: $e');
    }
  }

  /// Limpa todo o cache de items
  Future<void> clearCache() async {
    if (_prefs == null) return;

    try {
      final keys = _prefs!.getKeys();
      final itemsKeys = keys.where(
        (key) =>
            key.startsWith(_itemsKey) ||
            key.startsWith(_itemsByStockPrefix) ||
            key.startsWith('cached_item_') ||
            key.startsWith(_lastUpdateKey),
      );

      for (final key in itemsKeys) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      debugPrint('Erro ao limpar cache de items: $e');
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

  /// Verifica se tem cache válido para todos os items
  bool hasValidCache() {
    return _prefs != null && _isCacheValid() && _prefs!.containsKey(_itemsKey);
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

  /// Limpa items de cache por filtros (útil para invalidação seletiva)
  Future<void> clearCacheByFilters(ItemFilters filters) async {
    if (_prefs == null) return;

    try {
      // Se filtro por stock, limpa cache específico do stock
      if (filters.stockId != null) {
        await clearStockCache(filters.stockId!);
      }

      // Se filtro por status ou outros, limpa cache geral
      if (filters.status != null || filters.hasFilters) {
        await _prefs!.remove(_itemsKey);
        await _prefs!.remove(_lastUpdateKey);
      }
    } catch (e) {
      debugPrint('Erro ao limpar cache por filtros: $e');
    }
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
}
