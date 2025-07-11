import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/loans/controllers/loans_controller.dart';
import 'package:project_rotary/core/api/loans/models/loans_models.dart';
import 'package:project_rotary/core/api/loans/repositories/loans_repository.dart';
import 'package:project_rotary/core/api/loans/services/loans_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço principal para operações de loans
class LoansService {
  static LoansController? _instance;
  static bool _isInitialized = false;

  /// Inicializa o serviço de loans
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_isInitialized) return;

    try {
      final cacheService = LoansCacheService();
      final repository = LoansRepository(apiClient);
      final controller = LoansController(repository, cacheService);

      // Inicializa o controller (que por sua vez inicializa o cache)
      await controller.initialize();

      _instance = controller;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar LoansService: $e');
    }
  }

  /// Verifica se o serviço está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém a instância do controller
  static LoansController? get instance => _instance;

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      throw Exception(
        'LoansService não foi inicializado. Chame LoansService.initialize() primeiro.',
      );
    }
  }

  /// Reinicializa o serviço
  static Future<void> reinitialize({required ApiClient apiClient}) async {
    _isInitialized = false;
    _instance?.dispose();
    _instance = null;
    await initialize(apiClient: apiClient);
  }

  /// Dispose do serviço
  static void dispose() {
    _instance?.dispose();
    _instance = null;
    _isInitialized = false;
  }

  // === MÉTODOS DE CONVENIÊNCIA PARA LOANS ===

  /// Busca todos os loans (listagem)
  static AsyncResult<List<LoanListItem>> getLoans({
    bool forceRefresh = false,
    LoanFilters? filters,
  }) async {
    await ensureInitialized();
    return _instance!.loadLoans(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca um loan por ID
  static AsyncResult<Loan> getLoanById(
    String loanId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadLoanById(loanId, forceRefresh: forceRefresh);
  }

  /// Cria um novo loan
  static AsyncResult<Loan> createLoan(CreateLoanRequest request) async {
    await ensureInitialized();
    return _instance!.createLoan(request);
  }

  /// Atualiza um loan
  static AsyncResult<Loan> updateLoan(
    String loanId,
    UpdateLoanRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateLoan(loanId, request);
  }

  /// Deleta um loan
  static AsyncResult<bool> deleteLoan(String loanId) async {
    await ensureInitialized();
    return _instance!.deleteLoan(loanId);
  }

  /// Busca loans ativos (listagem)
  static AsyncResult<List<LoanListItem>> getActiveLoans({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadActiveLoans(forceRefresh: forceRefresh);
  }

  /// Busca loans devolvidos (listagem)
  static AsyncResult<List<LoanListItem>> getReturnedLoans({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadReturnedLoans(forceRefresh: forceRefresh);
  }

  /// Busca loans em atraso (listagem)
  static AsyncResult<List<LoanListItem>> getOverdueLoans({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadOverdueLoans(forceRefresh: forceRefresh);
  }

  /// Busca loans por período (listagem)
  static AsyncResult<List<LoanListItem>> getLoansByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadLoansByDateRange(
      startDate,
      endDate,
      forceRefresh: forceRefresh,
    );
  }

  // === OPERAÇÕES DE DEVOLUÇÃO ===

  /// Marca um loan como devolvido
  static AsyncResult<Loan> returnLoan(String loanId, [String? reason]) async {
    await ensureInitialized();
    return _instance!.returnLoan(loanId, reason);
  }

  /// Reativa um loan (caso tenha sido devolvido por engano)
  static AsyncResult<Loan> reactivateLoan(
    String loanId, [
    String? reason,
  ]) async {
    await ensureInitialized();
    return _instance!.reactivateLoan(loanId, reason);
  }

  // === ESTATÍSTICAS ===

  /// Busca estatísticas dos loans
  static AsyncResult<Map<String, dynamic>> getStatistics({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadStatistics(forceRefresh: forceRefresh);
  }

  // === OPERAÇÕES DE BUSCA E FILTRO ===

  /// Busca loans por texto (razão)
  static List<LoanListItem> searchLoans(String query) {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.searchLoans(query);
  }

  /// Filtra loans localmente
  static List<LoanListItem> filterLoans({
    bool? isActive,
    String? applicant,
    String? responsible,
    int? item,
    bool? isOverdue,
  }) {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.filterLoans(
      isActive: isActive,
      applicant: applicant,
      responsible: responsible,
      item: item,
      isOverdue: isOverdue,
    );
  }

  /// Ordena loans por data
  static List<LoanListItem> sortLoansByDate({bool ascending = false}) {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.sortLoansByDate(ascending: ascending);
  }

  /// Ordena loans por status (ativos primeiro)
  static List<LoanListItem> sortLoansByStatus() {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.sortLoansByStatus();
  }

  // === OPERAÇÕES DE CACHE ===

  /// Limpa todos os caches
  static Future<void> clearAllCaches() async {
    await ensureInitialized();
    await _instance!.clearAllCaches();
  }

  /// Força refresh de todos os dados
  static AsyncResult<List<LoanListItem>> refreshAllData() async {
    await ensureInitialized();
    return _instance!.refreshAllData();
  }

  /// Obtém informações do cache
  static Future<Map<String, dynamic>> getCacheInfo() async {
    if (!_isInitialized || _instance == null) return {};
    return await _instance!.getCacheInfo();
  }

  /// Obtém informações básicas do cache de forma síncrona
  static Map<String, dynamic> getCacheStatus() {
    if (!_isInitialized || _instance == null) return {};
    return _instance!.getCacheStatus();
  }

  /// Verifica se há dados no cache persistente
  static Future<bool> hasPersistedData() async {
    if (!_isInitialized || _instance == null) return false;
    final cacheInfo = await _instance!.getCacheInfo();
    return cacheInfo['persistent']?['hasLoansCache'] ?? false;
  }

  // === GETTERS DE ESTADO ===

  /// Lista atual de loans (listagem)
  static List<LoanListItem> get currentLoans {
    if (!_isInitialized || _instance == null) return [];
    return _instance!.loans;
  }

  /// Indica se está carregando
  static bool get isLoading {
    if (!_isInitialized || _instance == null) return false;
    return _instance!.isLoading;
  }

  /// Mensagem de erro, se houver
  static String? get error {
    if (!_isInitialized || _instance == null) return null;
    return _instance!.error;
  }

  /// Verifica se tem dados carregados
  static bool get hasData {
    if (!_isInitialized || _instance == null) return false;
    return _instance!.hasLoansData;
  }

  /// Estatísticas atuais
  static Map<String, dynamic>? get currentStatistics {
    if (!_isInitialized || _instance == null) return null;
    return _instance!.statistics;
  }

  // === MÉTODOS DE FACTORY ===

  /// Cria um LoanFilters facilmente
  static LoanFilters createFilters({
    String? applicantId,
    String? responsibleId,
    String? itemId,
    bool? isActive,
    String? reason,
    DateTime? createdAfter,
    DateTime? createdBefore,
    DateTime? returnAfter,
    DateTime? returnBefore,
    bool? isOverdue,
  }) {
    return LoanFilters(
      applicantId: applicantId,
      responsibleId: responsibleId,
      itemId: itemId,
      isActive: isActive,
      reason: reason,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
      returnAfter: returnAfter,
      returnBefore: returnBefore,
      isOverdue: isOverdue,
    );
  }

  /// Cria um CreateLoanRequest facilmente
  static CreateLoanRequest createLoanRequest({
    required String applicantId,
    required String responsibleId,
    required String itemId,
    String? reason,
  }) {
    return CreateLoanRequest(
      applicantId: applicantId,
      responsibleId: responsibleId,
      itemId: itemId,
      reason: reason,
    );
  }

  /// Cria um UpdateLoanRequest facilmente
  static UpdateLoanRequest createUpdateRequest({
    String? reason,
    bool? isActive,
  }) {
    return UpdateLoanRequest(reason: reason, isActive: isActive);
  }

  // === MÉTODOS DE UTILIDADE ===

  /// Valida se um loan request é válido
  static bool isValidLoanRequest(CreateLoanRequest request) {
    return request.applicantId.isNotEmpty &&
        request.responsibleId.isNotEmpty &&
        request.itemId.isNotEmpty;
  }

  /// Verifica se um loan está em atraso
  static bool isLoanOverdue(LoanListItem loan) {
    if (!loan.isActive) return false;
    final daysSinceLoan = DateTime.now().difference(loan.createdAt).inDays;
    return daysSinceLoan > 30; // Considera em atraso após 30 dias
  }

  /// Calcula os dias desde o empréstimo
  static int daysSinceLoan(LoanListItem loan) {
    return DateTime.now().difference(loan.createdAt).inDays;
  }

  /// Calcula os dias até a devolução (se houver data prevista)
  static int? daysUntilReturn(LoanListItem loan) {
    if (loan.returnDate == null) return null;
    return loan.returnDate!.difference(DateTime.now()).inDays;
  }
}
