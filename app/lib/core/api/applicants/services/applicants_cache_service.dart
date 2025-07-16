import 'dart:convert';

import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para applicants e dependents
class ApplicantsCacheService {
  static const String _applicantsCacheKey = 'applicants_cache';
  static const String _applicantCachePrefix = 'applicant_';
  static const String _dependentsCacheKey = 'dependents_cache';
  static const String _lastUpdateKey = 'applicants_last_update';
  static const Duration _cacheDuration = Duration(minutes: 5);

  SharedPreferences? _prefs;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Verifica se o cache está válido
  bool _isCacheValid(String key) {
    final lastUpdateStr = _prefs?.getString('${key}_timestamp');
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.tryParse(lastUpdateStr);
    if (lastUpdate == null) return false;

    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }

  /// Salva timestamp de atualização
  Future<void> _saveTimestamp(String key) async {
    await _prefs?.setString(
      '${key}_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  // === CACHE DE APPLICANTS ===

  /// Cache de todos os applicants
  Future<void> cacheApplicants(List<Applicant> applicants) async {
    await initialize();

    final applicantsJson = applicants
        .map((applicant) => applicant.toJson())
        .toList();
    await _prefs?.setString(_applicantsCacheKey, jsonEncode(applicantsJson));
    await _saveTimestamp(_applicantsCacheKey);
  }

  /// Obtém todos os applicants do cache
  Future<List<Applicant>?> getCachedApplicants() async {
    await initialize();

    if (!_isCacheValid(_applicantsCacheKey)) return null;

    final applicantsStr = _prefs?.getString(_applicantsCacheKey);
    if (applicantsStr == null) return null;

    try {
      final applicantsJson = jsonDecode(applicantsStr) as List;
      return applicantsJson
          .map((json) => Applicant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheCreatedApplicant(Applicant applicant) async {
    // busca a lista de applicants do cache
    final cachedApplicants = await getCachedApplicants() ?? [];
    // adiciona o novo applicant
    cachedApplicants.add(applicant);
    // atualiza o cache com a lista completa
    await cacheApplicants(cachedApplicants);
    // também cacheia o applicant individual
    await cacheApplicant(applicant);
  }

  /// Cache de um applicant individual
  Future<void> cacheApplicant(Applicant applicant) async {
    await initialize();

    final key = '$_applicantCachePrefix${applicant.id}';
    final json = applicant.toJson();

    await _prefs?.setString(key, jsonEncode(json));
    await _saveTimestamp(key);
  }

  /// Obtém um applicant específico do cache
  Future<Applicant?> getCachedApplicant(String applicantId) async {
    await initialize();

    final key = '$_applicantCachePrefix$applicantId';
    if (!_isCacheValid(key)) {
      debugPrint('DEBUG: Cache not valid for applicant $applicantId');
      return null;
    }

    final applicantStr = _prefs?.getString(key);
    if (applicantStr == null) {
      debugPrint('DEBUG: No cached data for applicant $applicantId');
      return null;
    }

    try {
      final applicantJson = jsonDecode(applicantStr) as Map<String, dynamic>;
      final applicant = Applicant.fromJson(applicantJson);

      return applicant;
    } catch (e) {
      debugPrint('DEBUG: Error parsing cached applicant $applicantId: $e');
      return null;
    }
  }

  /// Remove um applicant específico do cache
  Future<void> removeCachedApplicant(String applicantId) async {
    await initialize();

    final key = '$_applicantCachePrefix$applicantId';
    await _prefs?.remove(key);

    // remove da lista geral de applicants
    final cachedApplicants = await getCachedApplicants();
    if (cachedApplicants != null) {
      cachedApplicants.removeWhere((cached) => cached.id == applicantId);
      await cacheApplicants(cachedApplicants);
    }
  }

  /// Atualiza um applicant no cache
  Future<void> updateCachedApplicant(Applicant applicant) async {
    final cachedApplicant = await getCachedApplicant(applicant.id);

    // Cria uma nova instância do applicant preservando os dependents existentes
    final updatedApplicant =
        cachedApplicant != null && cachedApplicant.dependents != null
        ? applicant.copyWith(dependents: cachedApplicant.dependents)
        : applicant;

    // Atualiza o cache do applicant
    await cacheApplicant(updatedApplicant);

    // atualiza o cache da lista geral de applicants
    final cachedApplicants = await getCachedApplicants();
    if (cachedApplicants != null) {
      final updatedApplicants = cachedApplicants.map((cached) {
        return cached.id == applicant.id ? updatedApplicant : cached;
      }).toList();
      await cacheApplicants(updatedApplicants);
    }
  }

  /// Remove um dependent específico do cache
  Future<void> removeCachedDependent(
    String dependentId,
    String applicantId,
  ) async {
    // busca o applicant para remover o dependent
    final cachedApplicant = await getCachedApplicant(applicantId);
    if (cachedApplicant != null) {
      // Remove o dependent do cache do applicant
      final dependents = List<Dependent>.from(cachedApplicant.dependents ?? []);
      final existingIndex = dependents.indexWhere((d) => d.id == dependentId);
      if (existingIndex != -1) {
        dependents.removeAt(existingIndex);

        // Cria uma nova instância do applicant com os dependents atualizados
        final updatedApplicant = cachedApplicant.copyWith(
          dependents: dependents,
        );

        // Atualiza o cache do applicant
        await cacheApplicant(updatedApplicant);
      }
    }
  }

  /// Atualiza um dependent no cache
  Future<void> updateCachedDependent(Dependent dependent) async {
    // busca o applicant para atualizar os dependents
    final cachedApplicant = await getCachedApplicant(dependent.applicantId);
    if (cachedApplicant != null) {
      // Atualiza o dependent no cache do applicant
      final dependents = List<Dependent>.from(cachedApplicant.dependents ?? []);
      final existingIndex = dependents.indexWhere((d) => d.id == dependent.id);
      if (existingIndex != -1) {
        dependents[existingIndex] = dependent;
      } else {
        dependents.add(dependent);
      }

      // Cria uma nova instância do applicant com os dependents atualizados
      final updatedApplicant = cachedApplicant.copyWith(dependents: dependents);

      // Atualiza o cache do applicant
      await cacheApplicant(updatedApplicant);
    }
  }

  // === LIMPEZA E UTILITÁRIOS ===

  /// Limpa todo o cache de applicants
  Future<void> clearApplicantsCache() async {
    await initialize();

    // Remove cache geral
    await _prefs?.remove(_applicantsCacheKey);
    await _prefs?.remove('${_applicantsCacheKey}_timestamp');

    // Remove caches individuais
    final keys = _prefs?.getKeys() ?? <String>{};
    for (final key in keys) {
      if (key.startsWith(_applicantCachePrefix)) {
        await _prefs?.remove(key);
      }
    }
  }

  /// Limpa todo o cache
  Future<void> clearCache() async {
    await clearApplicantsCache();
    await _prefs?.remove(_lastUpdateKey);
  }

  /// Verifica se há dados em cache
  Future<bool> hasApplicantsCache() async {
    await initialize();
    return _prefs?.containsKey(_applicantsCacheKey) ?? false;
  }

  /// Obtém informações do cache
  Future<Map<String, dynamic>> getCacheInfo() async {
    await initialize();

    final applicantsTimestamp = _prefs?.getString(
      '${_applicantsCacheKey}_timestamp',
    );
    final dependentsTimestamp = _prefs?.getString(
      '${_dependentsCacheKey}_timestamp',
    );

    return {
      'hasApplicantsCache': await hasApplicantsCache(),
      'applicantsLastUpdate': applicantsTimestamp,
      'dependentsLastUpdate': dependentsTimestamp,
      'isApplicantsCacheValid': applicantsTimestamp != null
          ? _isCacheValid(_applicantsCacheKey)
          : false,
      'isDependentsCacheValid': dependentsTimestamp != null
          ? _isCacheValid(_dependentsCacheKey)
          : false,
      'cacheDurationMinutes': _cacheDuration.inMinutes,
    };
  }
}
