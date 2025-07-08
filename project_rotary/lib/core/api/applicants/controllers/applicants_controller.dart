import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/api/applicants/repositories/applicants_repository.dart';
import 'package:project_rotary/core/api/applicants/services/applicants_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de applicants e dependents
class ApplicantsController {
  final ApplicantsRepository _repository;
  final ApplicantsCacheService _cacheService;

  List<Applicant> _applicants = [];
  List<Dependent> _dependents = [];
  bool _isLoading = false;
  String? _error;

  ApplicantsController(this._repository, this._cacheService);

  /// Lista de applicants atual
  List<Applicant> get applicants => List.unmodifiable(_applicants);

  /// Lista de dependents atual
  List<Dependent> get dependents => List.unmodifiable(_dependents);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Verifica se tem dados de applicants carregados
  bool get hasApplicantsData => _applicants.isNotEmpty;

  /// Verifica se tem dados de dependents carregados
  bool get hasDependentsData => _dependents.isNotEmpty;

  // === OPERAÇÕES DE APPLICANTS ===

  /// Carrega todos os applicants
  AsyncResult<List<Applicant>> loadApplicants({
    bool forceRefresh = false,
    ApplicantFilters? filters,
  }) async {
    if (_isLoading) {
      return Success(_applicants);
    }

    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro, se não for refresh forçado e não tiver filtros
      if (!forceRefresh && filters == null) {
        final cachedApplicants = await _cacheService.getCachedApplicants();
        if (cachedApplicants != null) {
          _applicants = cachedApplicants;
          _isLoading = false;
          return Success(_applicants);
        }
      }

      // Busca da API
      final result = await _repository.getApplicants(filters: filters);

      return result.fold(
        (applicants) {
          _applicants = applicants;
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

          // Se falhar e não tiver cache, usa lista vazia
          if (_applicants.isEmpty) {
            return Failure(error);
          }

          // Se falhar mas tiver cache, retorna o cache
          return Success(_applicants);
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

        // Verifica na lista local
        try {
          final applicant = _applicants.firstWhere((a) => a.id == applicantId);
          return Success(applicant);
        } catch (e) {
          // Continua para buscar na API
        }
      }

      // Busca da API
      final result = await _repository.getApplicant(applicantId);

      return result.fold((applicant) {
        // Atualiza cache
        _cacheService.cacheApplicant(applicant);

        // Atualiza lista local se o applicant já existir
        final index = _applicants.indexWhere((a) => a.id == applicantId);
        if (index != -1) {
          _applicants[index] = applicant;
        } else {
          _applicants.add(applicant);
        }

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

      return result.fold((applicantId) {
        // Invalida cache para forçar refresh na próxima busca
        _cacheService.clearApplicantsCache();

        return Success(applicantId);
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

        // Atualiza lista local
        final index = _applicants.indexWhere((a) => a.id == applicantId);
        if (index != -1) {
          _applicants[index] = updatedApplicant;
        }

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

          // Remove da lista local
          _applicants.removeWhere((a) => a.id == applicantId);

          // Remove dependents relacionados
          _dependents.removeWhere((d) => d.applicantId == applicantId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar candidato: $e'));
    }
  }

  // === OPERAÇÕES DE DEPENDENTS ===

  /// Carrega todos os dependents
  AsyncResult<List<Dependent>> loadDependents({
    bool forceRefresh = false,
    DependentFilters? filters,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado e não tiver filtros
      if (!forceRefresh && filters == null) {
        final cachedDependents = await _cacheService.getCachedDependents();
        if (cachedDependents != null) {
          _dependents = cachedDependents;
          return Success(_dependents);
        }
      }

      // Busca da API
      final result = await _repository.getDependents(filters: filters);

      return result.fold((dependents) {
        _dependents = dependents;

        // Salva no cache apenas se não tiver filtros
        if (filters == null) {
          _cacheService.cacheDependents(dependents);
        }

        return Success(dependents);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao carregar dependentes: $e'));
    }
  }

  /// Busca dependents de um applicant específico
  AsyncResult<List<Dependent>> loadDependentsByApplicant(
    String applicantId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedDependents = await _cacheService
            .getCachedApplicantDependents(applicantId);
        if (cachedDependents != null) {
          return Success(cachedDependents);
        }
      }

      // Busca da API
      final result = await _repository.getDependentsByApplicant(applicantId);

      return result.fold((dependents) {
        // Atualiza cache
        _cacheService.cacheApplicantDependents(applicantId, dependents);

        // Atualiza lista local (substitui ou adiciona)
        _dependents.removeWhere((d) => d.applicantId == applicantId);
        _dependents.addAll(dependents);

        return Success(dependents);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao buscar dependentes do candidato: $e'));
    }
  }

  /// Busca um dependent por ID
  AsyncResult<Dependent> getDependent(
    String dependentId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedDependent = await _cacheService.getCachedDependent(
          dependentId,
        );
        if (cachedDependent != null) {
          return Success(cachedDependent);
        }

        // Verifica na lista local
        try {
          final dependent = _dependents.firstWhere((d) => d.id == dependentId);
          return Success(dependent);
        } catch (e) {
          // Continua para buscar na API
        }
      }

      // Busca da API
      final result = await _repository.getDependent(dependentId);

      return result.fold((dependent) {
        // Atualiza cache
        _cacheService.cacheDependent(dependent);

        // Atualiza lista local se o dependent já existir
        final index = _dependents.indexWhere((d) => d.id == dependentId);
        if (index != -1) {
          _dependents[index] = dependent;
        } else {
          _dependents.add(dependent);
        }

        return Success(dependent);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao buscar dependente: $e'));
    }
  }

  /// Cria um novo dependent
  AsyncResult<String> createDependent(CreateDependentRequest request) async {
    try {
      final result = await _repository.createDependent(request);

      return result.fold((dependentId) {
        // Invalida cache para forçar refresh na próxima busca
        _cacheService.clearDependentsCache();
        _cacheService.removeCachedApplicantDependents(request.applicantId);

        return Success(dependentId);
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

        // Atualiza lista local
        final index = _dependents.indexWhere((d) => d.id == dependentId);
        if (index != -1) {
          _dependents[index] = updatedDependent;
        }

        return Success(updatedDependent);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar dependente: $e'));
    }
  }

  /// Deleta um dependent
  AsyncResult<bool> deleteDependent(String dependentId) async {
    try {
      final result = await _repository.deleteDependent(dependentId);

      return result.fold((success) {
        if (success) {
          // Remove do cache
          _cacheService.removeCachedDependent(dependentId);

          // Remove da lista local
          _dependents.removeWhere((d) => d.id == dependentId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar dependente: $e'));
    }
  }

  // === OPERAÇÕES ESPECIAIS ===

  /// Busca applicants beneficiários
  AsyncResult<List<Applicant>> getBeneficiaryApplicants({
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(isBeneficiary: true);
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca applicants não beneficiários
  AsyncResult<List<Applicant>> getNonBeneficiaryApplicants({
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(isBeneficiary: false);
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca applicants por nome
  AsyncResult<List<Applicant>> searchApplicantsByName(
    String name, {
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(name: name);
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca applicants por CPF
  AsyncResult<List<Applicant>> searchApplicantsByCpf(
    String cpf, {
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(cpf: cpf);
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca applicants por email
  AsyncResult<List<Applicant>> searchApplicantsByEmail(
    String email, {
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(email: email);
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca applicants por período de criação
  AsyncResult<List<Applicant>> getApplicantsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    final filters = ApplicantFilters(
      createdAfter: startDate,
      createdBefore: endDate,
    );
    return loadApplicants(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca dependents por nome
  AsyncResult<List<Dependent>> searchDependentsByName(
    String name, {
    bool forceRefresh = false,
  }) async {
    final filters = DependentFilters(name: name);
    return loadDependents(forceRefresh: forceRefresh, filters: filters);
  }

  /// Busca dependents por período de criação
  AsyncResult<List<Dependent>> getDependentsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    bool forceRefresh = false,
  }) async {
    final filters = DependentFilters(
      createdAfter: startDate,
      createdBefore: endDate,
    );
    return loadDependents(forceRefresh: forceRefresh, filters: filters);
  }

  // === MÉTODOS UTILITÁRIOS ===

  /// Obtém estatísticas dos applicants
  Map<String, int> getApplicantsStatistics() {
    int totalApplicants = _applicants.length;
    int beneficiaryApplicants =
        _applicants.where((a) => a.isBeneficiary).length;
    int nonBeneficiaryApplicants =
        _applicants.where((a) => !a.isBeneficiary).length;
    int applicantsWithDependents =
        _applicants.where((a) => (a.dependents?.isNotEmpty ?? false)).length;
    int applicantsWithValidContact =
        _applicants.where((a) => a.hasValidContact).length;

    // Total de pessoas (applicants + dependents)
    int totalPeople = _applicants.fold(
      0,
      (sum, applicant) => sum + applicant.totalPeople,
    );

    return {
      'totalApplicants': totalApplicants,
      'beneficiaryApplicants': beneficiaryApplicants,
      'nonBeneficiaryApplicants': nonBeneficiaryApplicants,
      'applicantsWithDependents': applicantsWithDependents,
      'applicantsWithValidContact': applicantsWithValidContact,
      'totalDependents': _dependents.length,
      'totalPeople': totalPeople,
    };
  }

  /// Verifica se um applicant tem dependents
  bool hasApplicantDependents(String applicantId) {
    return _dependents.any((d) => d.applicantId == applicantId);
  }

  /// Obtém dependents de um applicant (lista local)
  List<Dependent> getApplicantDependentsLocal(String applicantId) {
    return _dependents.where((d) => d.applicantId == applicantId).toList();
  }

  /// Obtém applicant por CPF (lista local)
  Applicant? getApplicantByCpf(String cpf) {
    try {
      return _applicants.firstWhere((a) => a.cpf == cpf);
    } catch (e) {
      return null;
    }
  }

  /// Obtém applicant por email (lista local)
  Applicant? getApplicantByEmail(String email) {
    try {
      return _applicants.firstWhere((a) => a.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se CPF já está em uso
  bool isCpfInUse(String cpf, {String? excludeApplicantId}) {
    return _applicants.any(
      (a) =>
          a.cpf == cpf &&
          (excludeApplicantId == null || a.id != excludeApplicantId),
    );
  }

  /// Verifica se email já está em uso
  bool isEmailInUse(String email, {String? excludeApplicantId}) {
    return _applicants.any(
      (a) =>
          a.email == email &&
          (excludeApplicantId == null || a.id != excludeApplicantId),
    );
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _applicants.clear();
    _dependents.clear();
    _error = null;
    _isLoading = false;
    await _cacheService.clearCache();
  }

  /// Força atualização dos dados
  AsyncResult<List<Applicant>> refreshApplicants() async {
    return loadApplicants(forceRefresh: true);
  }

  /// Força atualização dos dependents
  AsyncResult<List<Dependent>> refreshDependents() async {
    return loadDependents(forceRefresh: true);
  }
}
