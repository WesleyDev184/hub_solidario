import 'package:app/core/api/loans/models/loans_models.dart';
import 'package:app/core/api/loans/repositories/loans_repository.dart';
import 'package:app/core/api/loans/services/loans_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de loans
class LoansController {
  final LoansRepository _repository;
  final LoansCacheService _cacheService;

  bool _isLoading = false;
  String? _error;

  LoansController(this._repository, this._cacheService);

  /// Inicializa o controller
  Future<void> initialize() async {
    await _cacheService.initialize();
  }

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Estatísticas dos loans
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? get statistics => _statistics;

  // === OPERAÇÕES DE LOANS ===

  /// Carrega todos os loans (listagem)
  AsyncResult<List<LoanListItem>> loadLoans({
    bool forceRefresh = false,
    LoanFilters? filters,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro
      if (!forceRefresh && filters == null) {
        final cachedLoans = await _cacheService.getLoans();
        if (cachedLoans != null && cachedLoans.isNotEmpty) {
          _isLoading = false;
          return Success(cachedLoans);
        }
      }

      // Busca dados via repository
      final result = await _repository.getLoans();

      return result.fold(
        (loans) async {
          _error = null;
          _isLoading = false;

          // Atualiza cache se não há filtros
          if (filters == null) {
            await _cacheService.cacheLoans(loans);
          }

          return Success(loans);
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

  /// Cria um novo loan
  AsyncResult<Loan> createLoan(CreateLoanRequest request) async {
    try {
      final result = await _repository.createLoan(request);

      return result.fold((loan) async {
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
          // Remove do cache
          await _cacheService.removeCachedLoan(loanId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Marca um loan como devolvido
  AsyncResult<Loan> returnLoan(String loanId, [String? reason]) async {
    final request = UpdateLoanRequest(isActive: false, reason: reason);
    return updateLoan(loanId, request);
  }

  /// Limpa todos os caches
  Future<void> clearAllCaches() async {
    await _cacheService.clearPersistentCache();
    _statistics = null;
  }

  /// Força refresh de todos os dados
  AsyncResult<List<LoanListItem>> refreshAllData() async {
    await clearAllCaches();
    return loadLoans(forceRefresh: true);
  }

  /// Limpa dados locais
  void clearLocalData() {
    _statistics = null;
    _error = null;
    _isLoading = false;
  }

  /// Dispose do controller
  void dispose() {
    clearLocalData();
  }
}
