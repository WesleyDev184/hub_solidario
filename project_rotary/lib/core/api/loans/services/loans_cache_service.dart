import 'dart:async';
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para loans
class LoansCacheService {
  static const Duration _defaultCacheDuration = Duration(minutes: 30);
  static const String _loansCacheKey = 'loans_cache';
  static const String _loanCachePrefix = 'loan_';

  SharedPreferences? _prefs;

  // Cache de loans
  List<LoanListItem>? _loans;
  DateTime? _loansLastUpdated;

  // Cache individual por loan
  final Map<String, LoanListItem> _loansCache = {};
  final Map<String, DateTime> _loansCacheTimestamp = {};

  // Cache por applicant
  final Map<String, List<Loan>> _loansByApplicantCache = {};
  final Map<String, DateTime> _loansByApplicantTimestamp = {};

  // Cache por item
  final Map<String, List<Loan>> _loansByItemCache = {};
  final Map<String, DateTime> _loansByItemTimestamp = {};

  // Cache por responsible
  final Map<String, List<Loan>> _loansByResponsibleCache = {};
  final Map<String, DateTime> _loansByResponsibleTimestamp = {};

  final Duration _cacheDuration;

  LoansCacheService({Duration? cacheDuration})
    : _cacheDuration = cacheDuration ?? _defaultCacheDuration;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    debugPrint('LoansCacheService: Inicializando serviço de cache');
    _prefs ??= await SharedPreferences.getInstance();
    clearAll();
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

    // Também atualiza o cache em memória
    this.loans = loans;
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

      // Também atualiza o cache em memória
      this.loans = loans;

      return loans;
    } catch (e) {
      debugPrint('LoansCacheService: Erro ao decodificar loans do cache: $e');
      return null;
    }
  }

  /// Cache de um loan individual (persistente)
  Future<void> cacheLoan(Loan loan) async {
    await initialize();

    final key = '$_loanCachePrefix${loan.id}';
    final json = loan.toJson();

    await _prefs?.setString(key, jsonEncode(json));
    await _saveTimestamp(key);
  }

  /// Obtém um loan específico do cache persistente (detalhado)
  Future<Loan?> getCachedLoan(String loanId) async {
    await initialize();

    final key = '$_loanCachePrefix$loanId';
    if (!_isCacheValid(key)) {
      debugPrint('LoansCacheService: Cache não válido para loan $loanId');
      return null;
    }

    final loanStr = _prefs?.getString(key);
    if (loanStr == null) {
      debugPrint(
        'LoansCacheService: Dados não encontrados no cache para loan $loanId',
      );
      return null;
    }

    try {
      final loanJson = jsonDecode(loanStr) as Map<String, dynamic>;
      return Loan.fromJson(loanJson);
    } catch (e) {
      debugPrint(
        'LoansCacheService: Erro ao decodificar loan $loanId do cache: $e',
      );
      return null;
    }
  }

  /// Remove um loan específico do cache persistente
  Future<void> removeCachedLoan(String loanId) async {
    await initialize();

    final key = '$_loanCachePrefix$loanId';
    await _prefs?.remove(key);
    await _prefs?.remove('${key}_timestamp');

    // Remove da lista geral de loans
    final cachedLoans = await getCachedLoans();
    if (cachedLoans != null) {
      cachedLoans.removeWhere((cached) => cached.id == loanId);
      await cacheLoans(cachedLoans);
    }
  }

  /// Atualiza um loan no cache persistente
  Future<void> updateCachedLoan(Loan loan) async {
    // Cacheia o loan individual
    await cacheLoan(loan);

    // Atualiza o cache da lista geral de loans
    final cachedLoans = await getCachedLoans();
    if (cachedLoans != null) {
      final updatedLoans =
          cachedLoans.map((cached) {
            return cached.id == loan.id ? LoanListItem.fromLoan(loan) : cached;
          }).toList();
      await cacheLoans(updatedLoans);
    }
  }

  /// Adiciona um loan criado ao cache persistente
  Future<void> cacheCreatedLoan(Loan loan) async {
    // Busca a lista de loans do cache
    final cachedLoans = await getCachedLoans() ?? [];
    // Adiciona o novo loan
    cachedLoans.add(LoanListItem.fromLoan(loan));
    // Atualiza o cache com a lista completa
    await cacheLoans(cachedLoans);
    debugPrint(
      'LoansCacheService: Loan ${loan.id} adicionado ao cache persistente',
    );
  }

  // === CACHE DE LOANS ===

  /// Obtém a lista de loans do cache (primeiro tenta persistente, depois memória)
  Future<List<LoanListItem>?> getLoans() async {
    // Primeiro tenta o cache persistente
    final persistentLoans = await getCachedLoans();
    if (persistentLoans != null) {
      debugPrint(
        'LoansCacheService: Retornando ${persistentLoans.length} loans do cache persistente',
      );
      return persistentLoans;
    }

    // Se não encontrar no persistente, tenta o cache em memória
    final memoryLoans = loans;
    if (memoryLoans != null) {
      debugPrint(
        'LoansCacheService: Retornando ${memoryLoans.length} loans do cache em memória',
      );
      return memoryLoans;
    }

    debugPrint('LoansCacheService: Nenhum cache de loans encontrado');
    return null;
  }

  /// Obtém a lista de loans do cache (apenas memória - método original)
  List<LoanListItem>? get loans {
    if (_loans == null || _isLoansExpired()) {
      debugPrint('LoansCacheService: Cache de loans expirado ou vazio');
      return null;
    }
    debugPrint(
      'LoansCacheService: Retornando ${_loans!.length} loans do cache',
    );
    return List.unmodifiable(_loans!);
  }

  /// Define a lista de loans no cache
  set loans(List<LoanListItem>? loans) {
    _loans = loans != null ? List.from(loans) : null;
    _loansLastUpdated = loans != null ? DateTime.now() : null;

    // Atualiza cache individual
    if (loans != null) {
      for (final loan in loans) {
        _setCachedLoan(loan);
      }
    }

    debugPrint(
      'LoansCacheService: Cache de loans atualizado com ${loans?.length ?? 0} itens',
    );
  }

  /// Verifica se o cache de loans expirou
  bool _isLoansExpired() {
    if (_loansLastUpdated == null) return true;
    return DateTime.now().difference(_loansLastUpdated!) > _cacheDuration;
  }

  // === CACHE INDIVIDUAL ===

  /// Define um loan específico no cache
  void _setCachedLoan(LoanListItem loan) {
    _loansCache[loan.id] = loan;
    _loansCacheTimestamp[loan.id] = DateTime.now();
  }

  /// Adiciona um loan ao cache
  void addLoan(Loan loan) {
    // Adiciona à lista geral se existir
    if (_loans != null) {
      final existingIndex = _loans!.indexWhere((l) => l.id == loan.id);
      if (existingIndex >= 0) {
        _loans![existingIndex] = LoanListItem.fromLoan(loan);
      } else {
        _loans!.add(LoanListItem.fromLoan(loan));
      }
    }

    // Limpa caches relacionados
    _clearRelatedCaches(LoanListItem.fromLoan(loan));

    debugPrint('LoansCacheService: Loan ${loan.id} adicionado ao cache');
  }

  /// Atualiza um loan no cache
  void updateLoan(Loan loan) {
    addLoan(loan); // Mesma lógica da adição
    debugPrint('LoansCacheService: Loan ${loan.id} atualizado no cache');
  }

  /// Remove um loan do cache
  void removeLoan(String loanId) {
    final loan = _loansCache[loanId];

    _loansCache.remove(loanId);
    _loansCacheTimestamp.remove(loanId);

    // Remove da lista geral se existir
    _loans?.removeWhere((l) => l.id == loanId);

    // Limpa caches relacionados
    if (loan != null) {
      _clearRelatedCaches(loan);
    }

    debugPrint('LoansCacheService: Loan $loanId removido do cache');
  }

  // === CACHE POR APPLICANT ===

  /// Obtém loans por applicant do cache
  List<LoanListItem>? getLoansByApplicant(String applicantId) {
    final loans = _loansByApplicantCache[applicantId];
    final timestamp = _loansByApplicantTimestamp[applicantId];

    if (loans == null || timestamp == null) {
      debugPrint(
        'LoansCacheService: Loans para applicant $applicantId não encontrados no cache',
      );
      return null;
    }

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _loansByApplicantCache.remove(applicantId);
      _loansByApplicantTimestamp.remove(applicantId);
      debugPrint(
        'LoansCacheService: Cache de loans para applicant $applicantId expirado',
      );
      return null;
    }

    debugPrint(
      'LoansCacheService: ${loans.length} loans para applicant $applicantId encontrados no cache',
    );
    return List.unmodifiable(loans);
  }

  /// Define loans por applicant no cache
  void setLoansByApplicant(String applicantId, List<LoanListItem> loans) {
    _loansByApplicantCache[applicantId] = List.from(loans);
    _loansByApplicantTimestamp[applicantId] = DateTime.now();

    // Atualiza cache individual
    for (final loan in loans) {
      _setCachedLoan(loan);
    }

    debugPrint(
      'LoansCacheService: Cache de loans para applicant $applicantId atualizado com ${loans.length} itens',
    );
  }

  // === CACHE POR ITEM ===

  /// Obtém loans por item do cache
  List<LoanListItem>? getLoansByItem(String itemId) {
    final loans = _loansByItemCache[itemId];
    final timestamp = _loansByItemTimestamp[itemId];

    if (loans == null || timestamp == null) {
      return null;
    }

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _loansByItemCache.remove(itemId);
      _loansByItemTimestamp.remove(itemId);
      return null;
    }

    return List.unmodifiable(loans);
  }

  /// Define loans por item no cache
  void setLoansByItem(String itemId, List<LoanListItem> loans) {
    _loansByItemCache[itemId] = List.from(loans);
    _loansByItemTimestamp[itemId] = DateTime.now();

    for (final loan in loans) {
      _setCachedLoan(loan);
    }
  }

  // === CACHE POR RESPONSIBLE ===

  /// Obtém loans por responsible do cache
  List<LoanListItem>? getLoansByResponsible(String responsibleId) {
    final loans = _loansByResponsibleCache[responsibleId];
    final timestamp = _loansByResponsibleTimestamp[responsibleId];

    if (loans == null || timestamp == null) {
      return null;
    }

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _loansByResponsibleCache.remove(responsibleId);
      _loansByResponsibleTimestamp.remove(responsibleId);
      return null;
    }

    return List.unmodifiable(loans);
  }

  /// Define loans por responsible no cache
  void setLoansByResponsible(String responsibleId, List<LoanListItem> loans) {
    _loansByResponsibleCache[responsibleId] = List.from(loans);
    _loansByResponsibleTimestamp[responsibleId] = DateTime.now();

    for (final loan in loans) {
      _setCachedLoan(loan);
    }
  }

  // === UTILITÁRIOS ===

  /// Limpa caches relacionados a um loan
  void _clearRelatedCaches(LoanListItem loan) {
    _loansByApplicantCache.remove(loan.applicant);
    _loansByApplicantTimestamp.remove(loan.applicant);

    _loansByItemCache.remove(loan.item.toString());
    _loansByItemTimestamp.remove(loan.item.toString());

    _loansByResponsibleCache.remove(loan.responsible);
    _loansByResponsibleTimestamp.remove(loan.responsible);
  }

  /// Verifica se há dados de loans no cache
  bool get hasLoansData => _loans != null && !_isLoansExpired();

  /// Verifica se o cache está vazio
  bool get isEmpty => _loans == null || _loans!.isEmpty;

  /// Número de loans no cache
  int get loansCount => _loans?.length ?? 0;

  /// Limpa todo o cache
  void clearAll() {
    _loans = null;
    _loansLastUpdated = null;

    _loansCache.clear();
    _loansCacheTimestamp.clear();

    _loansByApplicantCache.clear();
    _loansByApplicantTimestamp.clear();

    _loansByItemCache.clear();
    _loansByItemTimestamp.clear();

    _loansByResponsibleCache.clear();
    _loansByResponsibleTimestamp.clear();

    debugPrint('LoansCacheService: Todo o cache foi limpo');
  }

  /// Limpa todo o cache persistente
  Future<void> clearPersistentCache() async {
    await initialize();

    // Remove cache geral
    await _prefs?.remove(_loansCacheKey);
    await _prefs?.remove('${_loansCacheKey}_timestamp');

    // Remove caches individuais
    final keys = _prefs?.getKeys() ?? <String>{};
    for (final key in keys) {
      if (key.startsWith(_loanCachePrefix)) {
        await _prefs?.remove(key);
      }
    }

    debugPrint('LoansCacheService: Todo o cache persistente foi limpo');
  }

  /// Limpa cache de loans gerais
  void clearLoans() {
    _loans = null;
    _loansLastUpdated = null;
    debugPrint('LoansCacheService: Cache de loans limpo');
  }

  /// Limpa cache individual
  void clearIndividualCache() {
    _loansCache.clear();
    _loansCacheTimestamp.clear();
    debugPrint('LoansCacheService: Cache individual limpo');
  }

  /// Limpa cache por applicant
  void clearApplicantCache() {
    _loansByApplicantCache.clear();
    _loansByApplicantTimestamp.clear();
    debugPrint('LoansCacheService: Cache por applicant limpo');
  }

  /// Limpa cache por item
  void clearItemCache() {
    _loansByItemCache.clear();
    _loansByItemTimestamp.clear();
    debugPrint('LoansCacheService: Cache por item limpo');
  }

  /// Limpa cache por responsible
  void clearResponsibleCache() {
    _loansByResponsibleCache.clear();
    _loansByResponsibleTimestamp.clear();
    debugPrint('LoansCacheService: Cache por responsible limpo');
  }

  /// Status do cache para debug
  Map<String, dynamic> getCacheStatus() {
    return {
      'loans_count': loansCount,
      'loans_last_updated': _loansLastUpdated?.toIso8601String(),
      'loans_expired': _isLoansExpired(),
      'individual_cache_count': _loansCache.length,
      'applicant_cache_count': _loansByApplicantCache.length,
      'item_cache_count': _loansByItemCache.length,
      'responsible_cache_count': _loansByResponsibleCache.length,
    };
  }

  /// Verifica se há dados no cache persistente
  Future<bool> hasLoansPersistentCache() async {
    await initialize();
    return _prefs?.containsKey(_loansCacheKey) ?? false;
  }

  /// Obtém informações do cache persistente
  Future<Map<String, dynamic>> getCacheInfo() async {
    await initialize();

    final loansTimestamp = _prefs?.getString('${_loansCacheKey}_timestamp');

    return {
      'hasLoansCache': await hasLoansPersistentCache(),
      'loansLastUpdate': loansTimestamp,
      'isLoansCacheValid':
          loansTimestamp != null ? _isCacheValid(_loansCacheKey) : false,
      'cacheDurationMinutes': _cacheDuration.inMinutes,
      'memoryLoansCount': loansCount,
      'memoryLoansExpired': _isLoansExpired(),
    };
  }
}
