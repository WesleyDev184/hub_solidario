import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:project_rotary/core/api/loans/repositories/loans_repository.dart';
import 'package:project_rotary/core/api/loans/services/loans_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de loans
class LoansController {
  final LoansRepository _repository;
  final LoansCacheService _cacheService;

  List<LoanListItem> _loans = [];
  bool _isLoading = false;
  String? _error;

  LoansController(this._repository, this._cacheService);

  /// Inicializa o controller
  Future<void> initialize() async {
    await _cacheService.initialize();

    // Tenta carregar dados do cache na inicialização
    final cachedLoans = await _cacheService.getLoans();
    if (cachedLoans != null && cachedLoans.isNotEmpty) {
      _loans = cachedLoans;
    }
  }

  /// Lista de loans atual (listagem)
  List<LoanListItem> get loans => List.unmodifiable(_loans);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Verifica se tem dados de loans carregados
  bool get hasLoansData => _loans.isNotEmpty;

  /// Estatísticas dos loans
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? get statistics => _statistics;

  // === OPERAÇÕES DE LOANS ===

  /// Carrega todos os loans (listagem)
  AsyncResult<List<LoanListItem>> loadLoans({
    bool forceRefresh = false,
    LoanFilters? filters,
  }) async {
    if (_isLoading) {
      return Success(_loans);
    }

    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro
      if (!forceRefresh && filters == null) {
        final cachedLoans = await _cacheService.getLoans();
        if (cachedLoans != null && cachedLoans.isNotEmpty) {
          _loans = cachedLoans;
          _isLoading = false;
          return Success(_loans);
        }
      }

      // Busca dados via repository
      final result = await _repository.getLoans();

      return result.fold(
        (loans) async {
          final listItems = loans.map(LoanListItem.fromLoan).toList();
          _loans = listItems;
          _error = null;
          _isLoading = false;

          // Atualiza cache se não há filtros
          if (filters == null) {
            await _cacheService.cacheLoans(listItems);
          }

          return Success(listItems);
        },
        (error) {
          _error = error.toString();
          _isLoading = false;
          return Failure(error);
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Carrega um loan específico por ID (detalhado)
  AsyncResult<Loan> loadLoanById(
    String loanId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro
      if (!forceRefresh) {
        final cachedLoan = await _cacheService.getCachedLoan(loanId);
        if (cachedLoan != null) {
          return Success(cachedLoan);
        }
      }

      final result = await _repository.getLoanById(loanId);

      return result.fold((loan) async {
        // Atualiza cache
        await _cacheService.cacheLoan(loan);

        // Atualiza lista local se o loan já existe
        final index = _loans.indexWhere((l) => l.id == loan.id);
        if (index != -1) {
          _loans[index] = LoanListItem.fromLoan(loan);
        } else {
          _loans.add(LoanListItem.fromLoan(loan));
        }

        return Success(loan);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Cria um novo loan
  AsyncResult<Loan> createLoan(CreateLoanRequest request) async {
    try {
      final result = await _repository.createLoan(request);

      return result.fold((loan) async {
        // Adiciona à lista local
        _loans.add(LoanListItem.fromLoan(loan));

        // Atualiza cache
        await _cacheService.cacheCreatedLoan(loan);

        return Success(loan);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um loan existente
  AsyncResult<Loan> updateLoan(String loanId, UpdateLoanRequest request) async {
    try {
      final result = await _repository.updateLoan(loanId, request);

      return result.fold((loan) async {
        // Atualiza na lista local
        final index = _loans.indexWhere((l) => l.id == loan.id);
        if (index != -1) {
          _loans[index] = LoanListItem.fromLoan(loan);
        }

        // Atualiza cache
        await _cacheService.updateCachedLoan(loan);

        return Success(loan);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um loan
  AsyncResult<bool> deleteLoan(String loanId) async {
    try {
      final result = await _repository.deleteLoan(loanId);

      return result.fold((success) async {
        if (success) {
          // Remove da lista local
          _loans.removeWhere((loan) => loan.id == loanId);

          // Remove do cache
          await _cacheService.removeCachedLoan(loanId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Carrega loans ativos
  AsyncResult<List<LoanListItem>> loadActiveLoans({
    bool forceRefresh = false,
  }) async {
    final filters = LoanFilters(isActive: true);
    return loadLoans(forceRefresh: forceRefresh, filters: filters);
  }

  /// Carrega loans devolvidos
  AsyncResult<List<LoanListItem>> loadReturnedLoans({
    bool forceRefresh = false,
  }) async {
    final filters = LoanFilters(isActive: false);
    return loadLoans(forceRefresh: forceRefresh, filters: filters);
  }

  /// Carrega loans em atraso
  AsyncResult<List<LoanListItem>> loadOverdueLoans({
    bool forceRefresh = false,
  }) async {
    final filters = LoanFilters(isOverdue: true);
    return loadLoans(forceRefresh: forceRefresh, filters: filters);
  }

  /// Carrega loans por período
  AsyncResult<List<LoanListItem>> loadLoansByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    final filters = LoanFilters(
      createdAfter: startDate,
      createdBefore: endDate,
    );
    return loadLoans(forceRefresh: forceRefresh, filters: filters);
  }

  // === OPERAÇÕES DE DEVOLUÇÃO ===

  /// Marca um loan como devolvido
  AsyncResult<Loan> returnLoan(String loanId, [String? reason]) async {
    final request = UpdateLoanRequest(isActive: false, reason: reason);
    return updateLoan(loanId, request);
  }

  /// Reativa um loan (caso tenha sido devolvido por engano)
  AsyncResult<Loan> reactivateLoan(String loanId, [String? reason]) async {
    final request = UpdateLoanRequest(isActive: true, reason: reason);
    return updateLoan(loanId, request);
  }

  // === ESTATÍSTICAS ===

  /// Carrega estatísticas dos loans
  AsyncResult<Map<String, dynamic>> loadStatistics({
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro
      if (!forceRefresh && _statistics != null) {
        return Success(_statistics!);
      }

      final result = await _repository.getLoansStatistics();

      return result.fold((statistics) {
        _statistics = statistics;
        return Success(statistics);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  // === OPERAÇÕES DE BUSCA E FILTRO ===

  /// Busca loans por texto (razão)
  List<LoanListItem> searchLoans(String query) {
    if (query.isEmpty) return _loans;

    final searchQuery = query.toLowerCase();
    return _loans.where((loan) {
      return (loan.reason?.toLowerCase().contains(searchQuery) ?? false) ||
          (loan.applicant.toLowerCase().contains(searchQuery)) ||
          (loan.responsible.toLowerCase().contains(searchQuery));
    }).toList();
  }

  /// Filtra loans localmente
  List<LoanListItem> filterLoans({
    bool? isActive,
    String? applicant,
    String? responsible,
    int? item,
    bool? isOverdue,
  }) {
    return _loans.where((loan) {
      if (isActive != null && loan.isActive != isActive) return false;
      if (applicant != null && loan.applicant != applicant) return false;
      if (responsible != null && loan.responsible != responsible) return false;
      if (item != null && loan.item != item) return false;
      if (isOverdue != null && loan.isOverdue != isOverdue) return false;
      return true;
    }).toList();
  }

  /// Ordena loans por data
  List<LoanListItem> sortLoansByDate({bool ascending = false}) {
    final sortedLoans = List<LoanListItem>.from(_loans);
    sortedLoans.sort((a, b) {
      return ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
    return sortedLoans;
  }

  /// Ordena loans por status (ativos primeiro)
  List<LoanListItem> sortLoansByStatus() {
    final sortedLoans = List<LoanListItem>.from(_loans);
    sortedLoans.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sortedLoans;
  }

  // === OPERAÇÕES DE CACHE ===

  /// Limpa todos os caches
  Future<void> clearAllCaches() async {
    _cacheService.clearAll();
    await _cacheService.clearPersistentCache();
    _statistics = null;
  }

  /// Força refresh de todos os dados
  AsyncResult<List<LoanListItem>> refreshAllData() async {
    await clearAllCaches();
    return loadLoans(forceRefresh: true);
  }

  /// Obtém informações do cache
  Future<Map<String, dynamic>> getCacheInfo() async {
    final memoryInfo = _cacheService.getCacheStatus();
    final persistentInfo = await _cacheService.getCacheInfo();

    return {'memory': memoryInfo, 'persistent': persistentInfo};
  }

  /// Obtém informações básicas do cache de forma síncrona
  Map<String, dynamic> getCacheStatus() {
    return _cacheService.getCacheStatus();
  }

  // === OPERAÇÕES DE RESET ===

  /// Limpa dados locais
  void clearLocalData() {
    _loans.clear();
    _statistics = null;
    _error = null;
    _isLoading = false;
  }

  /// Dispose do controller
  void dispose() {
    clearLocalData();
  }
}
