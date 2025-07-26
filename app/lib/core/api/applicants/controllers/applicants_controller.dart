import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/api/applicants/repositories/applicants_repository.dart';
import 'package:app/core/api/applicants/services/applicants_cache_service.dart';
import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de applicants e dependents
class ApplicantsController extends GetxController {
  final ApplicantsRepository _repository;
  final ApplicantsCacheService _cacheService;
  final AuthController authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<Applicant> _applicants = <Applicant>[].obs;

  ApplicantsController(this._repository, this._cacheService);

  /// Indica se está carregando
  bool get isLoading => _isLoading.value;

  /// Mensagem de erro, se houver
  String? get error => _error.value.isEmpty ? null : _error.value;

  /// Lista de applicants
  List<Applicant> get allApplicants => _applicants.toList();

  @override
  void onInit() async {
    super.onInit();

    // Observa mudanças no estado de autenticação
    ever(authController.stateRx, (authState) async {
      if (authState.isAuthenticated) {
        await loadApplicants();
      } else {
        await clearData();
      }
    });

    // Carrega applicants se já estiver autenticado
    if (authController.isAuthenticated) {
      await loadApplicants();
    }
  }

  /// Carrega todos os applicants
  AsyncResult<List<Applicant>> loadApplicants({
    bool forceRefresh = false,
    ApplicantFilters? filters,
  }) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      // Verifica cache primeiro, se não for refresh forçado e não tiver filtros
      if (!forceRefresh && filters == null) {
        final cachedApplicants = await _cacheService.getCachedApplicants();
        if (cachedApplicants != null) {
          _applicants.assignAll(cachedApplicants);
          _isLoading.value = false;
          return Success(cachedApplicants);
        }
      }

      // Busca da API
      final result = await _repository.getApplicants(filters: filters);

      return result.fold(
        (applicants) {
          _isLoading.value = false;
          _error.value = '';
          _applicants.assignAll(applicants);

          // Salva no cache apenas se não tiver filtros
          if (filters == null) {
            _cacheService.cacheApplicants(applicants);
          }

          return Success(applicants);
        },
        (error) {
          _error.value = error.toString();
          _isLoading.value = false;
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro inesperado: $e';
      _isLoading.value = false;
      return Failure(Exception(_error.value));
    }
  }

  /// Busca um applicant por ID
  AsyncResult<Applicant> getApplicant(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh) {
        final cachedApplicant = await _cacheService.getCachedApplicant(
          applicantId,
        );
        if (cachedApplicant != null &&
            cachedApplicant.dependents?.isNotEmpty == true) {
          return Success(cachedApplicant);
        }
      }

      final result = await _repository.getApplicant(applicantId);
      return result.fold(
        (applicant) {
          _cacheService.cacheApplicant(applicant);
          updateApplicantInList(applicant);
          return Success(applicant);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao buscar candidato: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Cria um novo applicant
  AsyncResult<String> createApplicant(CreateApplicantRequest request) async {
    try {
      _isLoading.value = true;
      final result = await _repository.createApplicant(request);
      _isLoading.value = false;
      return result.fold(
        (applicant) {
          _cacheService.cacheCreatedApplicant(applicant);
          _applicants.add(applicant);
          return Success(applicant.id);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao criar candidato: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Atualiza um applicant existente
  AsyncResult<Applicant> updateApplicant(
    String applicantId,
    UpdateApplicantRequest request,
  ) async {
    try {
      _isLoading.value = true;
      final result = await _repository.updateApplicant(applicantId, request);
      _isLoading.value = false;
      return result.fold(
        (updatedApplicant) {
          _cacheService.updateCachedApplicant(updatedApplicant);
          updateApplicantInList(updatedApplicant);
          return Success(updatedApplicant);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao atualizar candidato: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Deleta um applicant
  AsyncResult<bool> deleteApplicant(String applicantId) async {
    try {
      _isLoading.value = true;
      final result = await _repository.deleteApplicant(applicantId);
      _isLoading.value = false;
      return result.fold(
        (success) {
          if (success) {
            _cacheService.removeCachedApplicant(applicantId);
            _applicants.removeWhere((a) => a.id == applicantId);
          }
          return Success(success);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao deletar candidato: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Cria um novo dependent
  AsyncResult<String> createDependent(CreateDependentRequest request) async {
    try {
      _isLoading.value = true;
      final result = await _repository.createDependent(request);
      _isLoading.value = false;
      return result.fold(
        (dependent) {
          _cacheService.updateCachedDependent(dependent);
          return Success(dependent.id);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao criar dependente: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Atualiza um dependent existente
  AsyncResult<Dependent> updateDependent(
    String dependentId,
    UpdateDependentRequest request,
  ) async {
    try {
      _isLoading.value = true;
      final result = await _repository.updateDependent(dependentId, request);
      _isLoading.value = false;
      return result.fold(
        (updatedDependent) {
          _cacheService.updateCachedDependent(updatedDependent);
          return Success(updatedDependent);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao atualizar dependente: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Deleta um dependent
  AsyncResult<bool> deleteDependent(
    String dependentId,
    String applicantId,
  ) async {
    try {
      _isLoading.value = true;
      final result = await _repository.deleteDependent(dependentId);
      _isLoading.value = false;
      return result.fold(
        (success) {
          if (success) {
            _cacheService.removeCachedDependent(dependentId, applicantId);
          }
          return Success(success);
        },
        (error) {
          _error.value = error.toString();
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = 'Erro ao deletar dependente: $e';
      return Failure(Exception(_error.value));
    }
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _error.value = '';
    _isLoading.value = false;
    _applicants.clear();
    await _cacheService.clearCache();
  }

  /// Atualiza applicant na lista local
  void updateApplicantInList(Applicant applicant) {
    final index = _applicants.indexWhere((a) => a.id == applicant.id);
    if (index != -1) {
      _applicants[index] = applicant;
    } else {
      _applicants.add(applicant);
    }
  }
}
