import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/api/applicants/repositories/applicants_repository.dart';
import 'package:project_rotary/core/api/applicants/services/applicants_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de applicants e dependents
class ApplicantsController {
  final ApplicantsRepository _repository;
  final ApplicantsCacheService _cacheService;

  bool _isLoading = false;
  String? _error;

  ApplicantsController(this._repository, this._cacheService);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Carrega todos os applicants
  AsyncResult<List<Applicant>> loadApplicants({
    bool forceRefresh = false,
    ApplicantFilters? filters,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro, se não for refresh forçado e não tiver filtros
      if (!forceRefresh && filters == null) {
        final cachedApplicants = await _cacheService.getCachedApplicants();
        if (cachedApplicants != null) {
          _isLoading = false;
          return Success(cachedApplicants);
        }
      }

      // Busca da API
      final result = await _repository.getApplicants(filters: filters);

      return result.fold(
        (applicants) {
          _isLoading = false;

          // Salva no cache apenas se não tiver filtros
          if (filters == null) {
            _cacheService.cacheApplicants(applicants);
          }

          return Success(applicants);
        },
        (error) {
          _error = error.toString();
          _isLoading = false;

          // Se falhar mas tiver cache, retorna o cache
          return Failure(error);
        },
      );
    } catch (e) {
      _error = 'Erro inesperado: $e';
      _isLoading = false;
      return Failure(Exception(_error!));
    }
  }

  /// Busca um applicant por ID
  AsyncResult<Applicant> getApplicant(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedApplicant = await _cacheService.getCachedApplicant(
          applicantId,
        );
        if (cachedApplicant != null) {
          return Success(cachedApplicant);
        }
      }

      // Busca da API
      final result = await _repository.getApplicant(applicantId);

      return result.fold((applicant) {
        // Atualiza cache
        _cacheService.cacheApplicant(applicant);

        return Success(applicant);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao buscar candidato: $e'));
    }
  }

  /// Cria um novo applicant
  AsyncResult<String> createApplicant(CreateApplicantRequest request) async {
    try {
      final result = await _repository.createApplicant(request);

      return result.fold((applicant) {
        // Invalida cache para forçar refresh na próxima busca
        _cacheService.cacheCreatedApplicant(applicant);

        return Success(applicant.id);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao criar candidato: $e'));
    }
  }

  /// Atualiza um applicant existente
  AsyncResult<Applicant> updateApplicant(
    String applicantId,
    UpdateApplicantRequest request,
  ) async {
    try {
      final result = await _repository.updateApplicant(applicantId, request);

      return result.fold((updatedApplicant) {
        // Atualiza cache
        _cacheService.updateCachedApplicant(updatedApplicant);

        return Success(updatedApplicant);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar candidato: $e'));
    }
  }

  /// Deleta um applicant
  AsyncResult<bool> deleteApplicant(String applicantId) async {
    try {
      final result = await _repository.deleteApplicant(applicantId);

      return result.fold((success) {
        if (success) {
          // Remove do cache
          _cacheService.removeCachedApplicant(applicantId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar candidato: $e'));
    }
  }

  /// Cria um novo dependent
  AsyncResult<String> createDependent(CreateDependentRequest request) async {
    try {
      final result = await _repository.createDependent(request);

      return result.fold((dependent) {
        _cacheService.updateCachedDependent(dependent);

        return Success(dependent.id);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao criar dependente: $e'));
    }
  }

  /// Atualiza um dependent existente
  AsyncResult<Dependent> updateDependent(
    String dependentId,
    UpdateDependentRequest request,
  ) async {
    try {
      final result = await _repository.updateDependent(dependentId, request);

      return result.fold((updatedDependent) {
        // Atualiza cache
        _cacheService.updateCachedDependent(updatedDependent);

        return Success(updatedDependent);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar dependente: $e'));
    }
  }

  /// Deleta um dependent
  AsyncResult<bool> deleteDependent(
    String dependentId,
    String applicantId,
  ) async {
    try {
      final result = await _repository.deleteDependent(dependentId);

      return result.fold((success) {
        if (success) {
          // Remove do cache
          _cacheService.removeCachedDependent(dependentId, applicantId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar dependente: $e'));
    }
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _error = null;
    _isLoading = false;
    await _cacheService.clearCache();
  }
}
