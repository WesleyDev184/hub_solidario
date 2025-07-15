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
  static AsyncResult<bool> deleteDependent(
    String dependentId,
    String applicantId,
  ) async {
    await ensureInitialized();
    return _instance!.deleteDependent(dependentId, applicantId);
  }

  /// Limpa cache de applicants
  static Future<void> clearCache() async {
    await ensureInitialized();
    return _instance!.clearData();
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
}
