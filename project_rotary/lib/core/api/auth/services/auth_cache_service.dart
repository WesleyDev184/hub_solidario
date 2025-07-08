import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';

/// Serviço de cache para dados de autenticação
class AuthCacheService {
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';

  final SharedPreferences _prefs;

  AuthCacheService._(this._prefs);

  /// Factory para criar instância do serviço
  static Future<AuthCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthCacheService._(prefs);
  }

  /// Salva o estado completo de autenticação
  Future<void> saveAuthState(AuthState state) async {
    try {
      if (state.user != null) {
        await _prefs.setString(_userKey, jsonEncode(state.user!.toJson()));
      } else {
        await _prefs.remove(_userKey);
      }

      if (state.token != null) {
        await _prefs.setString(_tokenKey, state.token!);
      } else {
        await _prefs.remove(_tokenKey);
      }

      if (state.refreshToken != null) {
        await _prefs.setString(_refreshTokenKey, state.refreshToken!);
      } else {
        await _prefs.remove(_refreshTokenKey);
      }

      if (state.tokenExpiry != null) {
        await _prefs.setString(
          _tokenExpiryKey,
          state.tokenExpiry!.toIso8601String(),
        );
      } else {
        await _prefs.remove(_tokenExpiryKey);
      }

      debugPrint('Auth state saved to cache');
    } catch (e) {
      debugPrint('Erro ao salvar estado de autenticação: $e');
    }
  }

  /// Carrega o estado de autenticação do cache
  Future<AuthState> loadAuthState() async {
    try {
      final userJson = _prefs.getString(_userKey);
      final token = _prefs.getString(_tokenKey);
      final refreshToken = _prefs.getString(_refreshTokenKey);
      final tokenExpiryString = _prefs.getString(_tokenExpiryKey);

      User? user;
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        user = User.fromJson(userMap);
      }

      DateTime? tokenExpiry;
      if (tokenExpiryString != null) {
        tokenExpiry = DateTime.parse(tokenExpiryString);
      }

      // Determina o status baseado nos dados disponíveis
      AuthStatus status = AuthStatus.unknown;
      if (token != null && user != null) {
        if (tokenExpiry != null && DateTime.now().isBefore(tokenExpiry)) {
          status = AuthStatus.authenticated;
        } else {
          status = AuthStatus.unauthenticated;
        }
      } else {
        status = AuthStatus.unauthenticated;
      }

      debugPrint('Auth state loaded from cache: $status');

      return AuthState(
        status: status,
        user: user,
        token: token,
        refreshToken: refreshToken,
        tokenExpiry: tokenExpiry,
      );
    } catch (e) {
      debugPrint('Erro ao carregar estado de autenticação: $e');
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Salva apenas o usuário
  Future<void> saveUser(User user) async {
    try {
      await _prefs.setString(_userKey, jsonEncode(user.toJson()));
      debugPrint('User saved to cache: ${user.email}');
    } catch (e) {
      debugPrint('Erro ao salvar usuário: $e');
    }
  }

  /// Carrega apenas o usuário
  Future<User?> loadUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
      return null;
    }
  }

  /// Salva apenas o token
  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
      debugPrint('Token saved to cache');
    } catch (e) {
      debugPrint('Erro ao salvar token: $e');
    }
  }

  /// Carrega apenas o token
  Future<String?> loadToken() async {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Erro ao carregar token: $e');
      return null;
    }
  }

  /// Salva dados de token completos
  Future<void> saveTokenData(AccessTokenResponse tokenResponse) async {
    try {
      await _prefs.setString(_tokenKey, tokenResponse.accessToken);
      await _prefs.setString(_refreshTokenKey, tokenResponse.refreshToken);

      // Calcula a data de expiração
      final expiry = DateTime.now().add(
        Duration(seconds: tokenResponse.expiresIn),
      );
      await _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());

      debugPrint('Token data saved to cache');
    } catch (e) {
      debugPrint('Erro ao salvar dados do token: $e');
    }
  }

  /// Verifica se existe um token válido no cache
  Future<bool> hasValidToken() async {
    try {
      final token = _prefs.getString(_tokenKey);
      final tokenExpiryString = _prefs.getString(_tokenExpiryKey);

      if (token == null || tokenExpiryString == null) {
        return false;
      }

      final tokenExpiry = DateTime.parse(tokenExpiryString);
      return DateTime.now().isBefore(tokenExpiry);
    } catch (e) {
      debugPrint('Erro ao verificar token válido: $e');
      return false;
    }
  }

  /// Limpa todos os dados de autenticação
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _prefs.remove(_userKey),
        _prefs.remove(_tokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_tokenExpiryKey),
      ]);
      debugPrint('Auth data cleared from cache');
    } catch (e) {
      debugPrint('Erro ao limpar dados de autenticação: $e');
    }
  }

  /// Atualiza apenas informações do usuário mantendo tokens
  Future<void> updateUser(User user) async {
    await saveUser(user);
  }

  /// Obtém o refresh token
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('Erro ao obter refresh token: $e');
      return null;
    }
  }

  /// Verifica se o usuário já fez login antes
  Future<bool> hasAuthData() async {
    try {
      final token = _prefs.getString(_tokenKey);
      final user = _prefs.getString(_userKey);
      return token != null || user != null;
    } catch (e) {
      debugPrint('Erro ao verificar dados de auth: $e');
      return false;
    }
  }
}
