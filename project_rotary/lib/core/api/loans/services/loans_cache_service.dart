import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para loans
class LoansCacheService {
  static const Duration _defaultCacheDuration = Duration(minutes: 30);
  static const String _loansCacheKey = 'loans_cache';

  SharedPreferences? _prefs;

  final Duration _cacheDuration;

  LoansCacheService({Duration? cacheDuration})
    : _cacheDuration = cacheDuration ?? _defaultCacheDuration;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Verifica se o cache está válido
  bool _isCacheValid(String key) {
    final lastUpdateStr = _prefs?.getString('${key}_timestamp');
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.tryParse(lastUpdateStr);
    if (lastUpdate == null) return false;

    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }

  /// Salva timestamp de atualização
  Future<void> _saveTimestamp(String key) async {
    await _prefs?.setString(
      '${key}_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  // === CACHE PERSISTENTE DE LOANS ===

  /// Cache de todos os loans (persistente)
  Future<void> cacheLoans(List<LoanListItem> loans) async {
    await initialize();

    final loansJson = loans.map((loan) => loan.toJson()).toList();
    await _prefs?.setString(_loansCacheKey, jsonEncode(loansJson));
    await _saveTimestamp(_loansCacheKey);
  }

  /// Obtém todos os loans do cache persistente (listagem)
  Future<List<LoanListItem>?> getCachedLoans() async {
    await initialize();

    if (!_isCacheValid(_loansCacheKey)) return null;

    final loansStr = _prefs?.getString(_loansCacheKey);
    if (loansStr == null) return null;

    try {
      final loansJson = jsonDecode(loansStr) as List;
      final loans =
          loansJson
              .map(
                (json) => LoanListItem.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return loans;
    } catch (e) {
      debugPrint('LoansCacheService: Erro ao decodificar loans do cache: $e');
      return null;
    }
  }

  /// Atualiza um loan no cache persistente
  Future<void> updateCachedLoan(Loan loan) async {
    // Busca a lista de loans do cache
    final cachedLoans = await getCachedLoans() ?? [];

    cachedLoans.removeWhere((l) => l.id == loan.id);

    if (loan.isActive) {
      // Adiciona o loan atualizado
      cachedLoans.add(LoanListItem.fromLoan(loan));
    }

    // Atualiza o cache com a lista completa
    await cacheLoans(cachedLoans);
  }

  /// Adiciona um loan criado ao cache persistente
  Future<void> cacheCreatedLoan(Loan loan) async {
    // Busca a lista de loans do cache
    final cachedLoans = await getCachedLoans() ?? [];
    // Adiciona o novo loan
    cachedLoans.add(LoanListItem.fromLoan(loan));
    // Atualiza o cache com a lista completa
    await cacheLoans(cachedLoans);
  }

  /// Remove um loan do cache persistente
  Future<void> removeCachedLoan(String loanId) async {
    // Busca a lista de loans do cache
    final cachedLoans = await getCachedLoans() ?? [];
    // Remove o loan pelo ID
    cachedLoans.removeWhere((loan) => loan.id == loanId);
    // Atualiza o cache com a lista completa
    await cacheLoans(cachedLoans);
  }

  /// Obtém a lista de loans do cache (primeiro tenta persistente, depois memória)
  Future<List<LoanListItem>?> getLoans() async {
    // Primeiro tenta o cache persistente
    final persistentLoans = await getCachedLoans();
    if (persistentLoans != null) {
      return persistentLoans;
    }

    return null;
  }

  /// Limpa todo o cache persistente
  Future<void> clearPersistentCache() async {
    await initialize();

    // Remove cache geral
    await _prefs?.remove(_loansCacheKey);
    await _prefs?.remove('${_loansCacheKey}_timestamp');

    debugPrint('LoansCacheService: Todo o cache persistente foi limpo');
  }
}
