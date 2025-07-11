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
  static const String _allUsersKey = 'auth_all_users';

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

      return AuthState(
        status: status,
        user: user,
        token: token,
        refreshToken: refreshToken,
        tokenExpiry: tokenExpiry,
      );
    } catch (e) {
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
        _prefs.remove(_allUsersKey),
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

  /// Salva a lista de todos os usuários
  Future<void> saveAllUsers(List<User> users) async {
    try {
      final usersJson = users.map((user) => user.toJson()).toList();
      await _prefs.setString(_allUsersKey, jsonEncode(usersJson));
      debugPrint('All users saved to cache: ${users.length} users');
    } catch (e) {
      debugPrint('Erro ao salvar todos os usuários: $e');
    }
  }

  /// Carrega a lista de todos os usuários
  Future<List<User>> loadAllUsers() async {
    try {
      final usersJson = _prefs.getString(_allUsersKey);
      if (usersJson != null) {
        final usersList = jsonDecode(usersJson) as List<dynamic>;
        return usersList
            .map((userMap) => User.fromJson(userMap as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar todos os usuários: $e');
      return [];
    }
  }

  /// Limpa o cache de todos os usuários
  Future<void> clearAllUsers() async {
    try {
      await _prefs.remove(_allUsersKey);
      debugPrint('All users cache cleared');
    } catch (e) {
      debugPrint('Erro ao limpar cache de todos os usuários: $e');
    }
  }

  /// Adiciona um usuário à lista de todos os usuários
  Future<void> addUserToAllUsers(User user) async {
    try {
      final currentUsers = await loadAllUsers();

      // Verifica se o usuário já existe (por ID)
      final existingIndex = currentUsers.indexWhere((u) => u.id == user.id);

      if (existingIndex >= 0) {
        // Atualiza o usuário existente
        currentUsers[existingIndex] = user;
      } else {
        // Adiciona o novo usuário
        currentUsers.add(user);
      }

      await saveAllUsers(currentUsers);
    } catch (e) {
      debugPrint('Erro ao adicionar usuário à lista: $e');
    }
  }

  /// Remove um usuário da lista de todos os usuários
  Future<void> removeUserFromAllUsers(String userId) async {
    try {
      final currentUsers = await loadAllUsers();
      currentUsers.removeWhere((user) => user.id == userId);
      await saveAllUsers(currentUsers);
    } catch (e) {
      debugPrint('Erro ao remover usuário da lista: $e');
    }
  }

  /// Verifica se existe cache de todos os usuários
  Future<bool> hasAllUsersCache() async {
    try {
      final usersJson = _prefs.getString(_allUsersKey);
      return usersJson != null && usersJson.isNotEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar cache de todos os usuários: $e');
      return false;
    }
  }

  /// Busca um usuário específico na lista de todos os usuários
  Future<User?> findUserInAllUsers(String userId) async {
    try {
      final allUsers = await loadAllUsers();
      return allUsers.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw StateError('User not found'),
      );
    } catch (e) {
      debugPrint('Usuário não encontrado na lista: $e');
      return null;
    }
  }
}
