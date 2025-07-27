import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/hubs/services/hubs_cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../models/hubs_models.dart';

/// Repositório para operações de hubs
class HubsRepository {
  final ApiClient _apiClient;

  HubsRepository({
    required ApiClient apiClient,
    required HubsCacheService cacheService,
  }) : _apiClient = apiClient;

  /// Cria um novo banco ortopédico
  AsyncResult<Hub> createHub(CreateHubRequest request) async {
    try {
      debugPrint('Creating hub: ${request.name}');

      final result = await _apiClient.post(
        '/hubs',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          final response = HubResponse.fromJson(
            success,
            (json) => Hub.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
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
  AsyncResult<List<Hub>> getHubs({bool forceRefresh = false}) async {
    try {
      final result = await _apiClient.get('/hubs', useAuth: true);

      return result.fold((success) async {
        try {
          final response = HubListResponse.fromJson(
            success,
            (json) => (json as List)
                .map((item) => Hub.fromJson(item as Map<String, dynamic>))
                .toList(),
          );

          if (response.success && response.data != null) {
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
  AsyncResult<Hub> getHub(String bankId) async {
    try {
      debugPrint('Getting orthopedic bank: $bankId');

      final result = await _apiClient.get('/hubs/$bankId', useAuth: true);

      return result.fold((success) async {
        try {
          final response = HubResponse.fromJson(
            success,
            (json) => Hub.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
            // Salva no cache
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
  AsyncResult<Hub> updateHub(String bankId, UpdateHubRequest request) async {
    try {
      final result = await _apiClient.patch(
        '/hubs/$bankId',
        request.toJson(),
        useAuth: true,
      );

      return result.fold((success) async {
        try {
          final response = HubResponse.fromJson(
            success,
            (json) => Hub.fromJson(json as Map<String, dynamic>),
          );

          if (response.success && response.data != null) {
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
  AsyncResult<bool> deleteHub(String bankId) async {
    try {
      final result = await _apiClient.delete('/hubs/$bankId', useAuth: true);

      return result.fold((success) {
        return Success(true);
      }, (failure) => Failure(failure));
    } catch (e) {
      debugPrint('Error deleting orthopedic bank: $e');
      return Failure(
        Exception('Erro ao deletar banco ortopédico: ${e.toString()}'),
      );
    }
  }
}
