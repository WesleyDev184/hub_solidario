import 'dart:convert';

import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:project_rotary/app/auth/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Classe responsável por persistir e recuperar dados de autenticação localmente
class AuthStorage {
  static const String _authDataKey = 'auth_data';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Salva os dados de autenticação no armazenamento local
  static Future<void> saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    final authDataJson = jsonEncode(authData.toMap());
    await prefs.setString(_authDataKey, authDataJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Salva os dados do usuário no armazenamento local
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toMap());
    await prefs.setString(_userDataKey, userJson);
  }

  /// Recupera os dados de autenticação do armazenamento local
  static Future<AuthData?> getAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authDataJson = prefs.getString(_authDataKey);

      if (authDataJson != null) {
        final authDataMap = jsonDecode(authDataJson) as Map<String, dynamic>;
        return AuthData.fromMap(authDataMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Recupera os dados do usuário do armazenamento local
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userDataKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromMap(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o usuário está logado
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      // Verifica se os dados ainda existem e são válidos
      if (isLoggedIn) {
        final authData = await getAuthData();
        if (authData != null && !authData.isExpired) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Remove todos os dados de autenticação do armazenamento local
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authDataKey);
    await prefs.remove(_userDataKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Verifica se o token ainda é válido baseado na data de expiração
  static Future<bool> isTokenValid() async {
    final authData = await getAuthData();
    return authData != null && !authData.isExpired;
  }
}
