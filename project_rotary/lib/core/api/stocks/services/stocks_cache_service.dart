import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_rotary/core/api/stocks/models/stocks_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para stocks usando SharedPreferences
class StocksCacheService {
  static const String _stocksKey = 'cached_stocks';
  static const String _stocksByBankPrefix = 'cached_stocks_bank_';
  static const String _lastUpdateKey = 'stocks_last_update';
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

  /// Salva a lista de stocks no cache
  Future<void> cacheStocks(List<Stock> stocks) async {
    if (_prefs == null) return;

    try {
      final stocksJson = stocks.map((stock) => stock.toJson()).toList();
      final jsonString = jsonEncode(stocksJson);

      await _prefs!.setString(_stocksKey, jsonString);
      await _prefs!.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erro ao salvar stocks no cache: $e');
    }
  }

  /// Recupera a lista de stocks do cache
  Future<List<Stock>?> getCachedStocks() async {
    if (_prefs == null || !_isCacheValid()) return null;

    try {
      final jsonString = _prefs!.getString(_stocksKey);
      if (jsonString == null) return null;

      final stocksJson = jsonDecode(jsonString) as List<dynamic>;
      return stocksJson
          .map((json) => Stock.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao recuperar stocks do cache: $e');
      return null;
    }
  }

  /// Salva stocks de um banco específico no cache
  Future<void> cacheStocksByBank(
    String orthopedicBankId,
    List<Stock> stocks,
  ) async {
    if (_prefs == null) return;

    try {
      final stocksJson = stocks.map((stock) => stock.toJson()).toList();
      final jsonString = jsonEncode(stocksJson);

      await _prefs!.setString(
        '$_stocksByBankPrefix$orthopedicBankId',
        jsonString,
      );
      await _prefs!.setString(
        '${_lastUpdateKey}_bank_$orthopedicBankId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint(
        'Erro ao salvar stocks do banco $orthopedicBankId no cache: $e',
      );
    }
  }

  /// Recupera stocks de um banco específico do cache
  Future<List<Stock>?> getCachedStocksByBank(String orthopedicBankId) async {
    if (_prefs == null) return null;

    try {
      // Verifica se o cache específico do banco é válido
      final lastUpdateStr = _prefs!.getString(
        '${_lastUpdateKey}_bank_$orthopedicBankId',
      );
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();

      if (now.difference(lastUpdate) >= _cacheExpiration) return null;

      final jsonString = _prefs!.getString(
        '$_stocksByBankPrefix$orthopedicBankId',
      );
      if (jsonString == null) return null;

      final stocksJson = jsonDecode(jsonString) as List<dynamic>;
      return stocksJson
          .map((json) => Stock.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(
        'Erro ao recuperar stocks do banco $orthopedicBankId do cache: $e',
      );
      return null;
    }
  }

  /// Salva um stock individual no cache
  Future<void> cacheStock(Stock stock) async {
    // busca a lista de stocks do cache
    final cachedStocks = await getCachedStocks() ?? [];

    try {
      // verifica se o stock já existe no cache
      final existingIndex = cachedStocks.indexWhere((s) => s.id == stock.id);
      if (existingIndex != -1) {
        // atualiza o stock existente
        cachedStocks[existingIndex] = stock;
      } else {
        // adiciona o novo stock
        cachedStocks.add(stock);
      }

      // salva a lista atualizada no cache
      await cacheStocks(cachedStocks);
    } catch (e) {
      debugPrint('Erro ao salvar stock ${stock.id} no cache: $e');
    }
  }

  /// Recupera um stock individual do cache
  Future<Stock?> getCachedStock(String stockId) async {
    if (_prefs == null) return null;

    try {
      final key = 'cached_stock_$stockId';

      // Verifica se o cache é válido
      final lastUpdateStr = _prefs!.getString('${key}_update');
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();

      if (now.difference(lastUpdate) >= _cacheExpiration) return null;

      final jsonString = _prefs!.getString(key);
      if (jsonString == null) return null;

      final stockJson = jsonDecode(jsonString) as Map<String, dynamic>;
      return Stock.fromJson(stockJson);
    } catch (e) {
      debugPrint('Erro ao recuperar stock $stockId do cache: $e');
      return null;
    }
  }

  /// Remove um stock específico do cache
  Future<void> removeStockFromCache(String stockId) async {
    // busca a lista de stocks do cache
    final cachedStocks = await getCachedStocks();
    if (cachedStocks == null) return;

    // remove o stock da lista
    cachedStocks.removeWhere((stock) => stock.id == stockId);

    await cacheStocks(cachedStocks);
  }

  /// Limpa todo o cache de stocks
  Future<void> clearCache() async {
    if (_prefs == null) return;

    try {
      final keys = _prefs!.getKeys();
      final stocksKeys = keys.where(
        (key) =>
            key.startsWith(_stocksKey) ||
            key.startsWith(_stocksByBankPrefix) ||
            key.startsWith('cached_stock_') ||
            key.startsWith(_lastUpdateKey),
      );

      for (final key in stocksKeys) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      debugPrint('Erro ao limpar cache de stocks: $e');
    }
  }

  /// Limpa cache de um banco específico
  Future<void> clearBankCache(String orthopedicBankId) async {
    if (_prefs == null) return;

    try {
      await _prefs!.remove('$_stocksByBankPrefix$orthopedicBankId');
      await _prefs!.remove('${_lastUpdateKey}_bank_$orthopedicBankId');
    } catch (e) {
      debugPrint('Erro ao limpar cache do banco $orthopedicBankId: $e');
    }
  }

  /// Verifica se tem cache válido para todos os stocks
  bool hasValidCache() {
    return _prefs != null && _isCacheValid() && _prefs!.containsKey(_stocksKey);
  }

  /// Verifica se tem cache válido para um banco específico
  bool hasValidBankCache(String orthopedicBankId) {
    if (_prefs == null) return false;

    final lastUpdateStr = _prefs!.getString(
      '${_lastUpdateKey}_bank_$orthopedicBankId',
    );
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();

    return now.difference(lastUpdate) < _cacheExpiration &&
        _prefs!.containsKey('$_stocksByBankPrefix$orthopedicBankId');
  }
}
