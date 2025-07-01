import 'package:project_rotary/app/auth/data/impl_auth_repository.dart';
import 'package:project_rotary/app/auth/domain/auth_repository.dart';
import 'package:project_rotary/app/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/get_orthopedic_banks_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/logout_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/signin_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/signup_usecase.dart';
import 'package:project_rotary/app/auth/domain/usecases/validate_token_usecase.dart';
import 'package:project_rotary/app/auth/presentation/controller/auth_controller.dart';
import 'package:project_rotary/core/api/api_client.dart';

/// Fábrica de dependências para o módulo de autenticação.
/// Centraliza a criação e configuração de todas as dependências,
/// seguindo o padrão de Dependency Injection e Clean Architecture.
/// Baseado no mesmo padrão implementado em loans, applicants e categories.
class AuthDependencyFactory {
  static AuthDependencyFactory? _instance;

  AuthDependencyFactory._();

  static AuthDependencyFactory get instance {
    _instance ??= AuthDependencyFactory._();
    return _instance!;
  }

  // ========================================
  // REPOSITÓRIOS E API CLIENT
  // ========================================

  ApiClient? _apiClient;
  AuthRepository? _authRepository;

  ApiClient get apiClient {
    _apiClient ??= ApiClient();
    return _apiClient!;
  }

  AuthRepository get authRepository {
    _authRepository ??= ImplAuthRepository(apiClient: apiClient);
    return _authRepository!;
  }

  // ========================================
  // USE CASES
  // ========================================

  SignInUseCase? _signInUseCase;
  SignUpUseCase? _signUpUseCase;
  LogoutUseCase? _logoutUseCase;
  IsLoggedInUseCase? _isLoggedInUseCase;
  GetCurrentUserUseCase? _getCurrentUserUseCase;
  RefreshTokenUseCase? _refreshTokenUseCase;
  ValidateTokenUseCase? _validateTokenUseCase;
  GetOrthopedicBanksUseCase? _getOrthopedicBanksUseCase;

  SignInUseCase get signInUseCase {
    _signInUseCase ??= SignInUseCase(repository: authRepository);
    return _signInUseCase!;
  }

  SignUpUseCase get signUpUseCase {
    _signUpUseCase ??= SignUpUseCase(repository: authRepository);
    return _signUpUseCase!;
  }

  LogoutUseCase get logoutUseCase {
    _logoutUseCase ??= LogoutUseCase(repository: authRepository);
    return _logoutUseCase!;
  }

  IsLoggedInUseCase get isLoggedInUseCase {
    _isLoggedInUseCase ??= IsLoggedInUseCase(repository: authRepository);
    return _isLoggedInUseCase!;
  }

  GetCurrentUserUseCase get getCurrentUserUseCase {
    _getCurrentUserUseCase ??= GetCurrentUserUseCase(
      repository: authRepository,
    );
    return _getCurrentUserUseCase!;
  }

  RefreshTokenUseCase get refreshTokenUseCase {
    _refreshTokenUseCase ??= RefreshTokenUseCase(repository: authRepository);
    return _refreshTokenUseCase!;
  }

  ValidateTokenUseCase get validateTokenUseCase {
    _validateTokenUseCase ??= ValidateTokenUseCase(repository: authRepository);
    return _validateTokenUseCase!;
  }

  GetOrthopedicBanksUseCase get getOrthopedicBanksUseCase {
    _getOrthopedicBanksUseCase ??= GetOrthopedicBanksUseCase(
      repository: authRepository,
    );
    return _getOrthopedicBanksUseCase!;
  }

  // ========================================
  // CONTROLLERS
  // ========================================

  AuthController? _authController;

  AuthController get authController {
    _authController ??= AuthController(
      signInUseCase: signInUseCase,
      signUpUseCase: signUpUseCase,
      logoutUseCase: logoutUseCase,
      isLoggedInUseCase: isLoggedInUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      refreshTokenUseCase: refreshTokenUseCase,
      validateTokenUseCase: validateTokenUseCase,
      getOrthopedicBanksUseCase: getOrthopedicBanksUseCase,
    );
    return _authController!;
  }

  // ========================================
  // RESET (para testes)
  // ========================================

  /// Reseta todas as instâncias. Útil para testes.
  void reset() {
    _instance = null;
    _authRepository = null;
    _signInUseCase = null;
    _signUpUseCase = null;
    _logoutUseCase = null;
    _isLoggedInUseCase = null;
    _getCurrentUserUseCase = null;
    _refreshTokenUseCase = null;
    _validateTokenUseCase = null;
    _getOrthopedicBanksUseCase = null;
    _authController = null;
  }
}
