import 'dart:convert';

import 'package:app/core/api/documents/models/documents_models.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de cache para documentos usando SharedPreferences
class DocumentsCacheService {
  static const String _documentsPrefix = 'cached_documents_';
  static const String _lastUpdateKey = 'documents_last_update';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  SharedPreferences? _prefs;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Salva documentos no cache
  Future<void> cacheDocuments(String applicantId, List<Document> documents) async {
    if (_prefs == null) return;
    try {
      final docsJson = documents.map((doc) => doc.toJson()).toList();
      final jsonString = jsonEncode(docsJson);
      await _prefs!.setString('$_documentsPrefix$applicantId', jsonString);
      await _prefs!.setString(
        '${_lastUpdateKey}_$applicantId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Erro ao salvar documentos no cache: $e');
    }
  }

  /// Recupera documentos do cache
  Future<List<Document>?> getCachedDocuments(String applicantId) async {
    if (_prefs == null) return null;
    try {
      final lastUpdateStr = _prefs!.getString('${_lastUpdateKey}_$applicantId');
      if (lastUpdateStr == null) return null;
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      if (now.difference(lastUpdate) >= _cacheExpiration) return null;
      final jsonString = _prefs!.getString('$_documentsPrefix$applicantId');
      if (jsonString == null) return null;
      final docsJson = jsonDecode(jsonString) as List<dynamic>;
      return docsJson
          .map((json) => Document.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao recuperar documentos do cache: $e');
      return null;
    }
  }

  /// Limpa o cache de documentos
  Future<void> clearCache(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove('$_documentsPrefix$key');
    await _prefs!.remove('${_lastUpdateKey}_$key');
  }
}
