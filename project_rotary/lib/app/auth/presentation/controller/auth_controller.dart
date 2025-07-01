import 'package:flutter/material.dart';
import 'package:project_rotary/app/auth/domain/dto/signin_dto.dart';
import 'package:project_rotary/app/auth/domain/dto/signup_dto.dart';
import 'package:project_rotary/app/auth/domain/entities/auth_data.dart';
import 'package:project_rotary/app/auth/domain/entities/orthopedic_bank.dart';
import 'package:project_rotary/app/auth/domain/entities/user.dart';
import 'package:project_rotary/app/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/get_orthopedic_banks_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/logout_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/signin_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/signup_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/validate_token_usecase.dart';
import 'package:result_dart/result_dart.dart';

/// Controller reativo para gerenciar o estado de autenticação.
/// Implementa o padrão Clean Architecture usando Use Cases.
/// Baseado no mesmo padrão implementado no LoanController e outros módulos.
class AuthController extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final ValidateTokenUseCase _validateTokenUseCase;
  final GetOrthopedicBanksUseCase _getOrthopedicBanksUseCase;

  AuthController({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required ValidateTokenUseCase validateTokenUseCase,
    required GetOrthopedicBanksUseCase getOrthopedicBanksUseCase,
  }) : _signInUseCase = signInUseCase,
       _signUpUseCase = signUpUseCase,
       _logoutUseCase = logoutUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _validateTokenUseCase = validateTokenUseCase,
       _getOrthopedicBanksUseCase = getOrthopedicBanksUseCase;

  // ========================================
  // ESTADO
  // ========================================

  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  AuthData? _authData;
  List<OrthopedicBank> _orthopedicBanks = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  AuthData? get authData => _authData;
  List<OrthopedicBank> get orthopedicBanks => _orthopedicBanks;
  bool get isAuthenticated => _authData != null && !_authData!.isExpired;

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setAuthData(AuthData? authData) {
    _authData = authData;
    notifyListeners();
  }

  void _setOrthopedicBanks(List<OrthopedicBank> orthopedicBanks) {
    _orthopedicBanks = orthopedicBanks;
    notifyListeners();
  }

  // ========================================
  // OPERAÇÕES DE AUTENTICAÇÃO
  // ========================================

  /// Realiza login no sistema
  AsyncResult<AuthData> signin({required SignInDTO signInDTO}) async {
    _setLoading(true);
    _setError(null);

    final result = await _signInUseCase(signInDTO: signInDTO);

    result.fold(
      (authData) {
        _setAuthData(authData);
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
        _setAuthData(null);
      },
    );

    _setLoading(false);
    return result;
  }

  /// Realiza cadastro no sistema
  AsyncResult<String> signup({required SignUpDTO signUpDTO}) async {
    _setLoading(true);
    _setError(null);

    final result = await _signUpUseCase(signUpDTO: signUpDTO);

    result.fold(
      (userId) {
        _setError(null);
        // Após criar usuário com sucesso, podemos buscar os dados do usuário atual
        getCurrentUser();
      },
      (failure) {
        _setError(failure.toString());
        _setCurrentUser(null);
      },
    );

    _setLoading(false);
    return result;
  }

  /// Realiza logout do sistema
  AsyncResult<String> logout() async {
    _setLoading(true);
    _setError(null);

    final result = await _logoutUseCase();

    result.fold(
      (message) {
        _setAuthData(null);
        _setCurrentUser(null);
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
      },
    );

    _setLoading(false);
    return result;
  }

  /// Verifica se o usuário está logado
  AsyncResult<bool> checkAuthStatus() async {
    _setLoading(true);
    _setError(null);

    final result = await _isLoggedInUseCase();

    result.fold(
      (isLoggedIn) {
        if (isLoggedIn) {
          // Se logado, busca dados do usuário atual
          getCurrentUser();
        } else {
          _setAuthData(null);
          _setCurrentUser(null);
        }
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
        _setAuthData(null);
        _setCurrentUser(null);
      },
    );

    _setLoading(false);
    return result;
  }

  /// Obtém dados do usuário atual
  AsyncResult<User> getCurrentUser() async {
    _setLoading(true);
    _setError(null);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (user) {
        _setCurrentUser(user);
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
        _setCurrentUser(null);
      },
    );

    _setLoading(false);
    return result;
  }

  /// Atualiza o token de acesso
  AsyncResult<AuthData> refreshToken({required String refreshToken}) async {
    _setLoading(true);
    _setError(null);

    final result = await _refreshTokenUseCase(refreshToken: refreshToken);

    result.fold(
      (authData) {
        _setAuthData(authData);
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
        _setAuthData(null);
      },
    );

    _setLoading(false);
    return result;
  }

  /// Valida um token de acesso
  AsyncResult<bool> validateToken({required String token}) async {
    final result = await _validateTokenUseCase(token: token);

    result.fold(
      (isValid) {
        if (!isValid) {
          _setAuthData(null);
          _setCurrentUser(null);
        }
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
      },
    );

    return result;
  }

  // ========================================
  // MÉTODOS DE CONVENIÊNCIA
  // ========================================

  /// Verifica se o token atual é válido
  Future<bool> isTokenValid() async {
    if (_authData == null) return false;

    if (_authData!.isExpired) {
      _setAuthData(null);
      _setCurrentUser(null);
      return false;
    }

    final result = await validateToken(token: _authData!.accessToken);
    return result.fold((isValid) => isValid, (failure) => false);
  }

  /// Tenta renovar o token se necessário
  Future<bool> ensureValidToken() async {
    if (_authData == null) return false;

    if (_authData!.isExpired) {
      final result = await refreshToken(refreshToken: _authData!.refreshToken);
      return result.isSuccess();
    }

    return await isTokenValid();
  }

  /// Busca todos os bancos ortopédicos disponíveis
  AsyncResult<List<OrthopedicBank>> getOrthopedicBanks() async {
    _setLoading(true);
    _setError(null);

    final result = await _getOrthopedicBanksUseCase();

    result.fold(
      (orthopedicBanks) {
        _setOrthopedicBanks(orthopedicBanks);
        _setError(null);
      },
      (failure) {
        _setError(failure.toString());
        _setOrthopedicBanks([]);
      },
    );

    _setLoading(false);
    return result;
  }
}
