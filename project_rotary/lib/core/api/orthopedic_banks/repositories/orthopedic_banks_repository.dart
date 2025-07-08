import 'package:flutter/foundation.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:result_dart/result_dart.dart';

import '../models/orthopedic_banks_models.dart';
import '../services/orthopedic_banks_cache_service.dart';

/// Repositório para operações de bancos ortopédicos
class OrthopedicBanksRepository {
  final ApiClient _apiClient;
  final OrthopedicBanksCacheService _cacheService;

  OrthopedicBanksRepository({
    required ApiClient apiClient,
    required OrthopedicBanksCacheService cacheService,
  }) : _apiClient = apiClient,
       _cacheService = cacheService;

  /// Cria um novo banco ortopédico
  AsyncResult<OrthopedicBank> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    try {
      debugPrint('Creating orthopedic bank: ${request.name}');

      final result = await _apiClient.post(
        '/orthopedic-banks',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          final response = OrthopedicBankResponse.fromJson(
            success,
            (json) => OrthopedicBank.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
            // Salva no cache
            await _cacheService.saveOrthopedicBank(response.data!);
            debugPrint(
              'Orthopedic bank created successfully: ${response.data!.name}',
            );
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao criar banco ortopédico'),
            );
          }
        } catch (e) {
          debugPrint('Error parsing create response: $e');
          return Failure(
            Exception('Erro ao processar resposta: ${e.toString()}'),
          );
        }
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error creating orthopedic bank: $e');
      return Failure(
        Exception('Erro ao criar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Obtém todos os bancos ortopédicos
  AsyncResult<List<OrthopedicBank>> getOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    try {
      debugPrint('Getting orthopedic banks, forceRefresh: $forceRefresh');

      // Verifica cache primeiro se não forçar refresh
      if (!forceRefresh) {
        final isExpired = await _cacheService.isCacheExpired();
        if (!isExpired) {
          final cachedState = await _cacheService.loadOrthopedicBanksState();
          if (cachedState.isNotEmpty) {
            debugPrint(
              'Returning cached orthopedic banks: ${cachedState.count}',
            );
            return Success(cachedState.banks);
          }
        }
      }

      final result = await _apiClient.get('/orthopedic-banks', useAuth: true);

      return result.fold((success) async {
        try {
          final response = OrthopedicBankListResponse.fromJson(
            success,
            (json) =>
                (json as List)
                    .map(
                      (item) =>
                          OrthopedicBank.fromJson(item as Map<String, dynamic>),
                    )
                    .toList(),
          );

          if (response.success && response.data != null) {
            // Salva no cache
            final state = OrthopedicBanksState(
              banks: response.data!,
              lastUpdated: DateTime.now(),
            );
            await _cacheService.saveOrthopedicBanksState(state);

            debugPrint('Orthopedic banks loaded: ${response.data!.length}');
            return Success(response.data!);
          } else {
            return Failure(
              Exception(
                response.message ?? 'Erro ao carregar bancos ortopédicos',
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing list response: $e');
          return Failure(
            Exception('Erro ao processar resposta: ${e.toString()}'),
          );
        }
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error getting orthopedic banks: $e');
      return Failure(
        Exception('Erro ao carregar bancos ortopédicos: ${e.toString()}'),
      );
    }
  }

  /// Obtém um banco ortopédico por ID
  AsyncResult<OrthopedicBank> getOrthopedicBank(String bankId) async {
    try {
      debugPrint('Getting orthopedic bank: $bankId');

      // Verifica cache primeiro
      final cachedBank = await _cacheService.getOrthopedicBank(bankId);
      if (cachedBank != null) {
        debugPrint('Returning cached orthopedic bank: ${cachedBank.name}');
        return Success(cachedBank);
      }

      final result = await _apiClient.get(
        '/orthopedic-banks/$bankId',
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          final response = OrthopedicBankResponse.fromJson(
            success,
            (json) => OrthopedicBank.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
            // Salva no cache
            await _cacheService.saveOrthopedicBank(response.data!);
            debugPrint('Orthopedic bank loaded: ${response.data!.name}');
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Banco ortopédico não encontrado'),
            );
          }
        } catch (e) {
          debugPrint('Error parsing get response: $e');
          return Failure(
            Exception('Erro ao processar resposta: ${e.toString()}'),
          );
        }
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error getting orthopedic bank: $e');
      return Failure(
        Exception('Erro ao carregar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Atualiza um banco ortopédico
  AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    try {
      debugPrint('Updating orthopedic bank: $bankId');

      final result = await _apiClient.patch(
        '/orthopedic-banks/$bankId',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          final response = OrthopedicBankResponse.fromJson(
            success,
            (json) => OrthopedicBank.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
            // Atualiza cache
            await _cacheService.saveOrthopedicBank(response.data!);
            debugPrint('Orthopedic bank updated: ${response.data!.name}');
            return Success(response.data!);
          } else {
            return Failure(
              Exception(
                response.message ?? 'Erro ao atualizar banco ortopédico',
              ),
            );
          }
        } catch (e) {
          debugPrint('Error parsing update response: $e');
          return Failure(
            Exception('Erro ao processar resposta: ${e.toString()}'),
          );
        }
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error updating orthopedic bank: $e');
      return Failure(
        Exception('Erro ao atualizar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Deleta um banco ortopédico
  AsyncResult<void> deleteOrthopedicBank(String bankId) async {
    try {
      debugPrint('Deleting orthopedic bank: $bankId');

      final result = await _apiClient.delete(
        '/orthopedic-banks/$bankId',
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          // Remove do cache
          await _cacheService.removeOrthopedicBank(bankId);
          debugPrint('Orthopedic bank deleted: $bankId');
          return Success(());
        } catch (e) {
          debugPrint('Error removing from cache: $e');
          return Success(()); // Sucesso mesmo se falhar no cache
        }
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error deleting orthopedic bank: $e');
      return Failure(
        Exception('Erro ao deletar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Carrega estado do cache
  Future<OrthopedicBanksState> loadCachedState() async {
    try {
      return await _cacheService.loadOrthopedicBanksState();
    } catch (e) {
      debugPrint('Error loading cached state: $e');
      return const OrthopedicBanksState();
    }
  }

  /// Limpa o cache
  Future<void> clearCache() async {
    try {
      await _cacheService.clearCache();
      debugPrint('Orthopedic banks cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
