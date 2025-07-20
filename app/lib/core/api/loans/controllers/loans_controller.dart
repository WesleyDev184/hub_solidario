import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/loans/models/loans_models.dart';
import 'package:app/core/api/loans/repositories/loans_repository.dart';
import 'package:app/core/api/loans/services/loans_cache_service.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

class LoansController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final LoansRepository _repository;
  final LoansCacheService _cacheService;

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<LoanListItem> _loans = <LoanListItem>[].obs;

  LoansController(this._repository, this._cacheService);

  /// Inicializa o controller
  @override
  void onInit() async {
    super.onInit();

    // Observa mudanças no estado de autenticação
    ever(authController.stateRx, (authState) async {
      if (authState.isAuthenticated) {
        await loadLoans();
      } else {
        await clearAllCaches();
      }
    });

    // Carrega loans se já estiver autenticado
    if (authController.isAuthenticated) {
      await loadLoans();
    }
  }

  /// Indica se está carregando
  bool get isLoading => _isLoading.value;

  /// Mensagem de erro, se houver
  String? get error => _error.value.isEmpty ? null : _error.value;

  /// Lista de loans
  List<LoanListItem> get allLoans => _loans.toList();

  /// Estatísticas dos loans
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? get statistics => _statistics;

  // === OPERAÇÕES DE LOANS ===

  /// Carrega todos os loans (listagem)
  AsyncResult<List<LoanListItem>> loadLoans({
    bool forceRefresh = false,
    LoanFilters? filters,
  }) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      // Verifica cache primeiro
      if (!forceRefresh && filters == null) {
        final cachedLoans = await _cacheService.getLoans();
        if (cachedLoans != null && cachedLoans.isNotEmpty) {
          _loans.assignAll(cachedLoans);
          _isLoading.value = false;
          return Success(cachedLoans);
        }
      }

      // Busca dados via repository
      final result = await _repository.getLoans();

      return result.fold(
        (loans) async {
          _error.value = '';
          _isLoading.value = false;
          _loans.assignAll(loans);

          // Atualiza cache se não há filtros
          if (filters == null) {
            await _cacheService.cacheLoans(loans);
          }

          return Success(loans);
        },
        (error) {
          _error.value = error.toString();
          _isLoading.value = false;
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Cria um novo loan
  AsyncResult<Loan> createLoan(CreateLoanRequest request) async {
    try {
      _isLoading.value = true;
      final result = await _repository.createLoan(request);
      _isLoading.value = false;
      return result.fold(
        (loan) async {
          await _cacheService.cacheCreatedLoan(loan);
          _loans.add(LoanListItem.fromLoan(loan));
          return Success(loan);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um loan existente
  AsyncResult<Loan> updateLoan(String loanId, UpdateLoanRequest request) async {
    try {
      _isLoading.value = true;
      final result = await _repository.updateLoan(loanId, request);
      _isLoading.value = false;
      return result.fold(
        (loan) async {
          await _cacheService.updateCachedLoan(loan);
          updateLoanInList(LoanListItem.fromLoan(loan));
          return Success(loan);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um loan
  AsyncResult<bool> deleteLoan(String loanId) async {
    try {
      _isLoading.value = true;
      final result = await _repository.deleteLoan(loanId);
      _isLoading.value = false;
      return result.fold(
        (success) async {
          if (success) {
            await _cacheService.removeCachedLoan(loanId);
            _loans.removeWhere((loan) => loan.id == loanId);
          }
          return Success(success);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
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
    _loans.clear();
  }

  /// Força refresh de todos os dados
  AsyncResult<List<LoanListItem>> refreshAllData() async {
    await clearAllCaches();
    return loadLoans(forceRefresh: true);
  }

  /// Limpa dados locais
  void clearLocalData() {
    _statistics = null;
    _error.value = '';
    _isLoading.value = false;
    _loans.clear();
  }

  /// Dispose do controller
  @override
  void dispose() {
    clearLocalData();
    super.dispose();
  }

  /// Atualiza loan na lista local
  void updateLoanInList(LoanListItem loan) {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index != -1) {
      _loans[index] = loan;
    } else {
      _loans.add(loan);
    }
  }
}
