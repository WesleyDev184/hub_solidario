import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';

/// Serviço de cache para loans
class LoansCacheService {
  static const Duration _defaultCacheDuration = Duration(minutes: 30);

  // Cache de loans
  List<Loan>? _loans;
  DateTime? _loansLastUpdated;

  // Cache individual por loan
  final Map<String, Loan> _loansCache = {};
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
    clearAll();
  }

  // === CACHE DE LOANS ===

  /// Obtém a lista de loans do cache
  List<Loan>? get loans {
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
  set loans(List<Loan>? loans) {
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

  /// Obtém um loan específico do cache
  Loan? getCachedLoan(String loanId) {
    final loan = _loansCache[loanId];
    final timestamp = _loansCacheTimestamp[loanId];

    if (loan == null || timestamp == null) {
      debugPrint('LoansCacheService: Loan $loanId não encontrado no cache');
      return null;
    }

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _loansCache.remove(loanId);
      _loansCacheTimestamp.remove(loanId);
      debugPrint('LoansCacheService: Cache do loan $loanId expirado');
      return null;
    }

    debugPrint('LoansCacheService: Loan $loanId encontrado no cache');
    return loan;
  }

  /// Define um loan específico no cache
  void _setCachedLoan(Loan loan) {
    _loansCache[loan.id] = loan;
    _loansCacheTimestamp[loan.id] = DateTime.now();
  }

  /// Adiciona um loan ao cache
  void addLoan(Loan loan) {
    _setCachedLoan(loan);

    // Adiciona à lista geral se existir
    if (_loans != null) {
      final existingIndex = _loans!.indexWhere((l) => l.id == loan.id);
      if (existingIndex >= 0) {
        _loans![existingIndex] = loan;
      } else {
        _loans!.add(loan);
      }
    }

    // Limpa caches relacionados
    _clearRelatedCaches(loan);

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
  List<Loan>? getLoansByApplicant(String applicantId) {
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
  void setLoansByApplicant(String applicantId, List<Loan> loans) {
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
  List<Loan>? getLoansByItem(String itemId) {
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
  void setLoansByItem(String itemId, List<Loan> loans) {
    _loansByItemCache[itemId] = List.from(loans);
    _loansByItemTimestamp[itemId] = DateTime.now();

    for (final loan in loans) {
      _setCachedLoan(loan);
    }
  }

  // === CACHE POR RESPONSIBLE ===

  /// Obtém loans por responsible do cache
  List<Loan>? getLoansByResponsible(String responsibleId) {
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
  void setLoansByResponsible(String responsibleId, List<Loan> loans) {
    _loansByResponsibleCache[responsibleId] = List.from(loans);
    _loansByResponsibleTimestamp[responsibleId] = DateTime.now();

    for (final loan in loans) {
      _setCachedLoan(loan);
    }
  }

  // === UTILITÁRIOS ===

  /// Limpa caches relacionados a um loan
  void _clearRelatedCaches(Loan loan) {
    _loansByApplicantCache.remove(loan.applicantId);
    _loansByApplicantTimestamp.remove(loan.applicantId);

    _loansByItemCache.remove(loan.itemId);
    _loansByItemTimestamp.remove(loan.itemId);

    _loansByResponsibleCache.remove(loan.responsibleId);
    _loansByResponsibleTimestamp.remove(loan.responsibleId);
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
}
