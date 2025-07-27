import 'dart:convert';

import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para applicants e dependents
class ApplicantsCacheService {
  static const String _applicantsCacheKey = 'cached_applicants';
  static const String _lastUpdateKey = 'applicants_last_update';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  SharedPreferences? _prefs;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva lista principal de applicants no cache
  Future<void> cacheApplicants(List<Applicant> applicants) async {
    if (_prefs == null) return;

    try {
      final applicantsJson = applicants.map((a) => a.toJson()).toList();
      final jsonString = jsonEncode(applicantsJson);
      await _prefs!.setString(_applicantsCacheKey, jsonString);
      await _prefs!.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erro ao salvar applicants no cache: $e');
    }
  }

  /// Adiciona um applicant à lista principal do cache
  Future<void> addApplicantToCache(Applicant applicant) async {
    if (_prefs == null) return;

    final cachedApplicants = await getCachedApplicants() ?? [];
    cachedApplicants.add(applicant);
    await cacheApplicants(cachedApplicants);
  }

  /// Recupera lista principal de applicants do cache
  Future<List<Applicant>?> getCachedApplicants() async {
    if (_prefs == null) return null;

    try {
      final lastUpdateStr = _prefs!.getString(_lastUpdateKey);
      if (lastUpdateStr == null) return null;

      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      if (now.difference(lastUpdate) >= _cacheExpiration) return null;

      final jsonString = _prefs!.getString(_applicantsCacheKey);
      if (jsonString == null) return null;

      final applicantsJson = jsonDecode(jsonString) as List<dynamic>;
      return applicantsJson
          .map((json) => Applicant.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao recuperar applicants do cache: $e');
      return null;
    }
  }

  /// Adiciona um applicant individual ao cache
  Future<void> cacheApplicant(Applicant applicant) async {
    if (_prefs == null) return;

    final cachedApplicants = await getCachedApplicants() ?? [];
    // Verifica se já existe
    final existingIndex = cachedApplicants.indexWhere(
      (a) => a.id == applicant.id,
    );
    if (existingIndex != -1) {
      // Atualiza o existente
      cachedApplicants[existingIndex] = applicant;
    } else {
      // Adiciona novo
      cachedApplicants.add(applicant);
    }
    await cacheApplicants(cachedApplicants);
  }

  /// Atualiza um applicant existente no cache
  Future<void> updateApplicantInCache(Applicant applicant) async {
    if (_prefs == null) return;

    final cachedApplicants = await getCachedApplicants() ?? [];
    final existingIndex = cachedApplicants.indexWhere(
      (a) => a.id == applicant.id,
    );
    if (existingIndex != -1) {
      cachedApplicants[existingIndex] = applicant;
      await cacheApplicants(cachedApplicants);
    }
  }

  /// Remove um applicant do cache
  Future<void> removeApplicantFromCache(String applicantId) async {
    if (_prefs == null) return;

    final cachedApplicants = await getCachedApplicants() ?? [];
    cachedApplicants.removeWhere((a) => a.id == applicantId);
    await cacheApplicants(cachedApplicants);
  }

  /// Limpa todo o cache de applicants
  Future<void> clearCache() async {
    if (_prefs == null) return;

    try {
      await _prefs!.remove(_applicantsCacheKey);
      await _prefs!.remove(_lastUpdateKey);
    } catch (e) {
      debugPrint('Erro ao limpar cache de applicants: $e');
    }
  }

  /// Verifica se tem cache válido
  bool hasValidCache() {
    if (_prefs == null) return false;

    final lastUpdateStr = _prefs!.getString(_lastUpdateKey);
    if (lastUpdateStr == null) return false;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final now = DateTime.now();
    return now.difference(lastUpdate) < _cacheExpiration &&
        _prefs!.containsKey(_applicantsCacheKey);
  }
}
