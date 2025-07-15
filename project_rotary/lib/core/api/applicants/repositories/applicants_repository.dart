import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de applicants e dependents via API
class ApplicantsRepository {
  final ApiClient _apiClient;

  const ApplicantsRepository(this._apiClient);

  // === OPERAÇÕES DE APPLICANTS ===

  /// Busca todos os applicants
  AsyncResult<List<Applicant>> getApplicants({
    ApplicantFilters? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams();
      final result = await _apiClient.get(
        '/applicants',
        useAuth: true,
        queryParams: queryParams,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final applicantsData = data['data'] as List;
            final applicants =
                applicantsData
                    .map(
                      (json) =>
                          Applicant.fromJson(json as Map<String, dynamic>),
                    )
                    .toList();
            return Success(applicants);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao buscar candidatos'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos candidatos: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um applicant por ID
  AsyncResult<Applicant> getApplicant(String applicantId) async {
    try {
      final result = await _apiClient.get(
        '/applicants/$applicantId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final applicant = Applicant.fromJson(
              data['data'] as Map<String, dynamic>,
            );

            // Debug: Verificar se os dependentes estão vindo da API
            print(
              'DEBUG: API returned applicant ${applicant.id} with ${applicant.dependents?.length ?? 0} dependents',
            );
            if (applicant.dependents != null) {
              for (final dep in applicant.dependents!) {
                print('DEBUG: API dependent ${dep.id} - ${dep.name}');
              }
            }

            return Success(applicant);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Candidato não encontrado'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do candidato: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo applicant
  AsyncResult<Applicant> createApplicant(CreateApplicantRequest request) async {
    try {
      final result = await _apiClient.post(
        '/applicants',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            // A API retorna o objeto completo do applicant, extrair o ID
            final applicantData = Applicant.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            return Success(applicantData);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao criar candidato'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da criação: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um applicant existente
  AsyncResult<Applicant> updateApplicant(
    String applicantId,
    UpdateApplicantRequest request,
  ) async {
    try {
      if (!request.hasUpdates) {
        return Failure(
          Exception('Nenhum campo foi fornecido para atualização'),
        );
      }

      final result = await _apiClient.patch(
        '/applicants/$applicantId',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final applicant = Applicant.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            return Success(applicant);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao atualizar candidato'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da atualização: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um applicant
  AsyncResult<bool> deleteApplicant(String applicantId) async {
    try {
      final result = await _apiClient.delete(
        '/applicants/$applicantId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true) {
            return Success(true);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao deletar candidato'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  // === OPERAÇÕES DE DEPENDENTS ===

  /// Busca todos os dependents
  AsyncResult<List<Dependent>> getDependents({
    DependentFilters? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams();
      final result = await _apiClient.get(
        '/dependents',
        useAuth: true,
        queryParams: queryParams,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final dependentsData = data['data'] as List;
            final dependents =
                dependentsData
                    .map(
                      (json) =>
                          Dependent.fromJson(json as Map<String, dynamic>),
                    )
                    .toList();
            return Success(dependents);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao buscar dependentes'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos dependentes: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um dependent por ID
  AsyncResult<Dependent> getDependent(String dependentId) async {
    try {
      final result = await _apiClient.get(
        '/dependents/$dependentId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final dependent = Dependent.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            return Success(dependent);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Dependente não encontrado'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta do dependente: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo dependent
  AsyncResult<Dependent> createDependent(CreateDependentRequest request) async {
    try {
      final result = await _apiClient.post(
        '/dependents',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final dependentData = Dependent.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            return Success(dependentData);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao criar dependente'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da criação: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um dependent existente
  AsyncResult<Dependent> updateDependent(
    String dependentId,
    UpdateDependentRequest request,
  ) async {
    try {
      if (!request.hasUpdates) {
        return Failure(
          Exception('Nenhum campo foi fornecido para atualização'),
        );
      }

      final result = await _apiClient.patch(
        '/dependents/$dependentId',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true && data['data'] != null) {
            final dependent = Dependent.fromJson(
              data['data'] as Map<String, dynamic>,
            );
            return Success(dependent);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao atualizar dependente'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da atualização: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um dependent
  AsyncResult<bool> deleteDependent(String dependentId) async {
    try {
      final result = await _apiClient.delete(
        '/dependents/$dependentId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          if (data['success'] == true) {
            return Success(true);
          } else {
            return Failure(
              Exception(data['message'] ?? 'Erro ao deletar dependente'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }
}
