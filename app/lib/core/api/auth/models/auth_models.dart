import 'package:app/core/api/hubs/models/hubs_models.dart';

/// Modelo para requisição de login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
  );

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Modelo para resposta de token de acesso
class AccessTokenResponse {
  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final String refreshToken;

  const AccessTokenResponse({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory AccessTokenResponse.fromJson(Map<String, dynamic> json) =>
      AccessTokenResponse(
        tokenType: json['tokenType'] as String,
        accessToken: json['accessToken'] as String,
        expiresIn: json['expiresIn'] as int,
        refreshToken: json['refreshToken'] as String,
      );

  Map<String, dynamic> toJson() => {
    'tokenType': tokenType,
    'accessToken': accessToken,
    'expiresIn': expiresIn,
    'refreshToken': refreshToken,
  };
}

/// Modelo para usuário
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final Hub? hub;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.hub,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    hub: json['hub'] != null
        ? Hub.fromJson(json['hub'] as Map<String, dynamic>)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'hub': hub?.toJson(),
    'createdAt': createdAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    Hub? orthopedicBank,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hub: hub ?? this.hub,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Modelo para criação de usuário
class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String hubId;

  const CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.hubId,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      CreateUserRequest(
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
        phoneNumber: json['phoneNumber'] as String,
        hubId: json['hubId'] as String,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phoneNumber': phoneNumber,
    'hubId': hubId,
  };
}

/// Modelo para atualização de usuário
class UpdateUserRequest {
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNumber;

  const UpdateUserRequest({
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      UpdateUserRequest(
        name: json['name'] as String?,
        email: json['email'] as String?,
        password: json['password'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (email != null) map['email'] = email;
    if (password != null) map['password'] = password;
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    return map;
  }
}

/// Modelo para resposta padrão do controller
class ControllerResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? count;

  const ControllerResponse({
    required this.success,
    this.data,
    this.message,
    this.count,
  });

  factory ControllerResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => ControllerResponse<T>(
    success: json['success'] as bool,
    data: json['data'] != null ? fromJsonT(json['data']) : null,
    message: json['message'] as String?,
    count: json['count'] as int?,
  );

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
    'success': success,
    'data': data != null ? toJsonT(data as T) : null,
    'message': message,
    'count': count,
  };
}

/// Tipo específico para resposta de usuário único
typedef UserResponse = ControllerResponse<User>;

/// Tipo específico para resposta de lista de usuários
typedef UserListResponse = ControllerResponse<List<User>>;

/// Estado da autenticação
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado completo da autenticação
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? refreshToken;
  final DateTime? tokenExpiry;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.refreshToken,
    this.tokenExpiry,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? refreshToken,
    DateTime? tokenExpiry,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isUnknown => status == AuthStatus.unknown;

  bool get isTokenExpired {
    if (tokenExpiry == null) return true;
    return DateTime.now().isAfter(tokenExpiry!);
  }
}
