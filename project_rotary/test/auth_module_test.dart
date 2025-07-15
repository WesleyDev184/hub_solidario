import 'package:flutter_test/flutter_test.dart';
import 'package:project_rotary/core/api/api_client.dart';
import 'package:project_rotary/core/api/auth/auth.dart';

void main() {
  group('Auth Module Tests', () {
    late ApiClient apiClient;
    late AuthController authController;

    setUpAll(() async {
      // Inicialização do módulo de teste
      apiClient = ApiClient();
      authController = await AuthService.initialize(
        apiClient: apiClient,
        apiKey: 'test-api-key',
      );
    });

    test('should initialize with unauthenticated state', () {
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, null);
    });

    test('should handle login process', () async {
      // Este teste requer um servidor de teste ou mock
      // Por enquanto, teste apenas a estrutura

      expect(authController.login, isA<Function>());
      expect(authController.logout, isA<Function>());
    });

    test('should create auth models correctly', () {
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(loginRequest.email, 'test@example.com');
      expect(loginRequest.password, 'password123');

      final json = loginRequest.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');

      final fromJson = LoginRequest.fromJson(json);
      expect(fromJson.email, loginRequest.email);
      expect(fromJson.password, loginRequest.password);
    });

    test('should create update user request correctly', () {
      final updateRequest = UpdateUserRequest(
        name: 'New Name',
        phoneNumber: '11999999999',
      );

      final json = updateRequest.toJson();
      expect(json['name'], 'New Name');
      expect(json['phoneNumber'], '11999999999');
      expect(json.containsKey('email'), false);
      expect(json.containsKey('password'), false);
    });

    test('should handle auth state correctly', () {
      const state = AuthState(status: AuthStatus.unauthenticated);

      expect(state.isAuthenticated, false);
      expect(state.isUnauthenticated, true);
      expect(state.isUnknown, false);

      final authenticatedState = state.copyWith(
        status: AuthStatus.authenticated,
      );

      expect(authenticatedState.isAuthenticated, true);
      expect(authenticatedState.isUnauthenticated, false);
    });

    tearDownAll(() async {
      await AuthService.reset();
    });
  });

  group('Auth Models Serialization Tests', () {
    test('User model serialization', () {
      final user = User(
        id: 'test-id',
        name: 'Test User',
        email: 'test@example.com',
        phoneNumber: '11999999999',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser.id, user.id);
      expect(deserializedUser.name, user.name);
      expect(deserializedUser.email, user.email);
      expect(deserializedUser.phoneNumber, user.phoneNumber);
    });

    test('AccessTokenResponse model serialization', () {
      final tokenResponse = AccessTokenResponse(
        tokenType: 'Bearer',
        accessToken: 'test-token',
        expiresIn: 3600,
        refreshToken: 'refresh-token',
      );

      final json = tokenResponse.toJson();
      final deserialized = AccessTokenResponse.fromJson(json);

      expect(deserialized.tokenType, tokenResponse.tokenType);
      expect(deserialized.accessToken, tokenResponse.accessToken);
      expect(deserialized.expiresIn, tokenResponse.expiresIn);
      expect(deserialized.refreshToken, tokenResponse.refreshToken);
    });

    test('CreateUserRequest model serialization', () {
      final request = CreateUserRequest(
        name: 'New User',
        email: 'new@example.com',
        password: 'password123',
        phoneNumber: '11888888888',
        orthopedicBankId: 'bank-id',
      );

      final json = request.toJson();
      final deserialized = CreateUserRequest.fromJson(json);

      expect(deserialized.name, request.name);
      expect(deserialized.email, request.email);
      expect(deserialized.password, request.password);
      expect(deserialized.phoneNumber, request.phoneNumber);
      expect(deserialized.orthopedicBankId, request.orthopedicBankId);
    });
  });
}
