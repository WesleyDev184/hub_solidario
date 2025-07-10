import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/applicants/controllers/applicants_controller.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/api/applicants/repositories/applicants_repository.dart';
import 'package:project_rotary/core/api/applicants/services/applicants_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Serviço principal para operações de applicants e dependents
class ApplicantsService {
  static ApplicantsController? _instance;
  static bool _isInitialized = false;

  /// Inicializa o serviço de applicants
  static Future<void> initialize({required ApiClient apiClient}) async {
    if (_isInitialized) return;

    try {
      final cacheService = ApplicantsCacheService();
      await cacheService.initialize();

      final repository = ApplicantsRepository(apiClient);
      final controller = ApplicantsController(repository, cacheService);

      _instance = controller;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Erro ao inicializar ApplicantsService: $e');
    }
  }

  /// Verifica se o serviço está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém a instância do controller
  static ApplicantsController? get instance => _instance;

  /// Garante que o serviço está inicializado
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      // Tenta reinicializar automaticamente se possível
      try {
        final apiClient = ApiClient();
        await initialize(apiClient: apiClient);
      } catch (e) {
        throw Exception(
          'ApplicantsService não foi inicializado. Chame ApplicantsService.initialize() primeiro. Erro: $e',
        );
      }
    }
  }

  /// Reinicializa o serviço
  static Future<void> reinitialize({required ApiClient apiClient}) async {
    _isInitialized = false;
    _instance = null;
    await initialize(apiClient: apiClient);
  }

  /// Encerra o serviço
  static Future<void> dispose() async {
    if (_instance != null) {
      await _instance!.clearData();
    }
    _instance = null;
    _isInitialized = false;
  }

  // === MÉTODOS DE CONVENIÊNCIA PARA APPLICANTS ===

  /// Carrega todos os applicants
  static AsyncResult<List<Applicant>> getApplicants({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadApplicants(forceRefresh: forceRefresh);
  }

  /// Busca um applicant por ID
  static AsyncResult<Applicant> getApplicant(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getApplicant(applicantId, forceRefresh: forceRefresh);
  }

  /// Cria um novo applicant
  static AsyncResult<String> createApplicant(
    CreateApplicantRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.createApplicant(request);
  }

  /// Atualiza um applicant existente
  static AsyncResult<Applicant> updateApplicant(
    String applicantId,
    UpdateApplicantRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateApplicant(applicantId, request);
  }

  /// Deleta um applicant
  static AsyncResult<bool> deleteApplicant(String applicantId) async {
    await ensureInitialized();
    return _instance!.deleteApplicant(applicantId);
  }

  /// Busca applicants beneficiários
  static AsyncResult<List<Applicant>> getBeneficiaryApplicants({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getBeneficiaryApplicants(forceRefresh: forceRefresh);
  }

  /// Busca applicants não beneficiários
  static AsyncResult<List<Applicant>> getNonBeneficiaryApplicants({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getNonBeneficiaryApplicants(forceRefresh: forceRefresh);
  }

  /// Busca applicants com filtros
  static AsyncResult<List<Applicant>> searchApplicants({
    String? name,
    String? cpf,
    String? email,
    bool? isBeneficiary,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();

    final filters = ApplicantFilters(
      name: name,
      cpf: cpf,
      email: email,
      isBeneficiary: isBeneficiary,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
    );

    return _instance!.loadApplicants(
      forceRefresh: forceRefresh,
      filters: filters,
    );
  }

  /// Busca applicants por nome
  static AsyncResult<List<Applicant>> searchApplicantsByName(
    String name, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.searchApplicantsByName(name, forceRefresh: forceRefresh);
  }

  /// Busca applicants por CPF
  static AsyncResult<List<Applicant>> searchApplicantsByCpf(
    String cpf, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.searchApplicantsByCpf(cpf, forceRefresh: forceRefresh);
  }

  /// Busca applicants por email
  static AsyncResult<List<Applicant>> searchApplicantsByEmail(
    String email, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.searchApplicantsByEmail(
      email,
      forceRefresh: forceRefresh,
    );
  }

  /// Busca applicants por período de criação
  static AsyncResult<List<Applicant>> getApplicantsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getApplicantsByDateRange(
      startDate,
      endDate,
      forceRefresh: forceRefresh,
    );
  }

  // === MÉTODOS DE CONVENIÊNCIA PARA DEPENDENTS ===

  /// Carrega todos os dependents
  static AsyncResult<List<Dependent>> getDependents({
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadDependents(forceRefresh: forceRefresh);
  }

  /// Busca dependents por applicant
  static AsyncResult<List<Dependent>> getDependentsByApplicant(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.loadDependentsByApplicant(
      applicantId,
      forceRefresh: forceRefresh,
    );
  }

  /// Busca um dependent por ID
  static AsyncResult<Dependent> getDependent(
    String dependentId, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getDependent(dependentId, forceRefresh: forceRefresh);
  }

  /// Cria um novo dependent
  static AsyncResult<String> createDependent(
    CreateDependentRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.createDependent(request);
  }

  /// Atualiza um dependent existente
  static AsyncResult<Dependent> updateDependent(
    String dependentId,
    UpdateDependentRequest request,
  ) async {
    await ensureInitialized();
    return _instance!.updateDependent(dependentId, request);
  }

  /// Deleta um dependent
  static AsyncResult<bool> deleteDependent(String dependentId,String applicantId) async {
    await ensureInitialized();
    return _instance!.deleteDependent(dependentId, applicantId);
  }

  /// Busca dependents com filtros
  static AsyncResult<List<Dependent>> searchDependents({
    String? name,
    String? cpf,
    String? email,
    String? applicantId,
    DateTime? createdAfter,
    DateTime? createdBefore,
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();

    final filters = DependentFilters(
      name: name,
      cpf: cpf,
      email: email,
      applicantId: applicantId,
      createdAfter: createdAfter,
      createdBefore: createdBefore,
    );

    return _instance!.loadDependents(
      forceRefresh: forceRefresh,
      filters: filters,
    );
  }

  /// Busca dependents por nome
  static AsyncResult<List<Dependent>> searchDependentsByName(
    String name, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.searchDependentsByName(name, forceRefresh: forceRefresh);
  }

  /// Busca dependents por período de criação
  static AsyncResult<List<Dependent>> getDependentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    await ensureInitialized();
    return _instance!.getDependentsByDateRange(
      startDate,
      endDate,
      forceRefresh: forceRefresh,
    );
  }

  // === MÉTODOS UTILITÁRIOS ===

  /// Obtém estatísticas dos applicants
  static Map<String, int> getApplicantsStatistics() {
    if (!_isInitialized || _instance == null) {
      return {};
    }
    return _instance!.getApplicantsStatistics();
  }

  /// Verifica se um applicant tem dependents
  static bool hasApplicantDependents(String applicantId) {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.hasApplicantDependents(applicantId);
  }

  /// Obtém dependents de um applicant (lista local)
  static List<Dependent> getApplicantDependentsLocal(String applicantId) {
    if (!_isInitialized || _instance == null) {
      return [];
    }
    return _instance!.getApplicantDependentsLocal(applicantId);
  }

  /// Obtém applicant por CPF (lista local)
  static Applicant? getApplicantByCpf(String cpf) {
    if (!_isInitialized || _instance == null) {
      return null;
    }
    return _instance!.getApplicantByCpf(cpf);
  }

  /// Obtém applicant por email (lista local)
  static Applicant? getApplicantByEmail(String email) {
    if (!_isInitialized || _instance == null) {
      return null;
    }
    return _instance!.getApplicantByEmail(email);
  }

  /// Verifica se CPF já está em uso
  static bool isCpfInUse(String cpf, {String? excludeApplicantId}) {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.isCpfInUse(cpf, excludeApplicantId: excludeApplicantId);
  }

  /// Verifica se email já está em uso
  static bool isEmailInUse(String email, {String? excludeApplicantId}) {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.isEmailInUse(
      email,
      excludeApplicantId: excludeApplicantId,
    );
  }

  /// Limpa cache de applicants
  static Future<void> clearCache() async {
    await ensureInitialized();
    return _instance!.clearData();
  }

  // === GETTERS DE ESTADO ===

  /// Lista atual de applicants
  static List<Applicant> get applicants {
    if (!_isInitialized || _instance == null) {
      return [];
    }
    return _instance!.applicants;
  }

  /// Lista atual de dependents
  static List<Dependent> get dependents {
    if (!_isInitialized || _instance == null) {
      return [];
    }
    return _instance!.dependents;
  }

  /// Indica se está carregando
  static bool get isLoading {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.isLoading;
  }

  /// Mensagem de erro atual
  static String? get error {
    if (!_isInitialized || _instance == null) {
      return null;
    }
    return _instance!.error;
  }

  /// Verifica se tem dados de applicants carregados
  static bool get hasApplicantsData {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.hasApplicantsData;
  }

  /// Verifica se tem dados de dependents carregados
  static bool get hasDependentsData {
    if (!_isInitialized || _instance == null) {
      return false;
    }
    return _instance!.hasDependentsData;
  }
}
