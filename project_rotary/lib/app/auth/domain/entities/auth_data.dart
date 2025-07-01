/// Entidade que representa dados de autenticação no sistema seguindo AccessTokenResponse da API.
/// Segue os princípios de Clean Architecture implementados em loans, applicants e categories.
class AuthData {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const AuthData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  AuthData copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
  }) {
    return AuthData(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  /// Calcula a data de expiração baseada no timestamp atual + expiresIn
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  /// Verifica se o token está expirado
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'tokenType': tokenType,
    };
  }

  factory AuthData.fromMap(Map<String, dynamic> map) {
    return AuthData(
      accessToken: map['accessToken'] ?? '',
      refreshToken: map['refreshToken'] ?? '',
      expiresIn: map['expiresIn'] ?? 0,
      tokenType: map['tokenType'] ?? 'Bearer',
    );
  }

  /// Factory para criar a partir da resposta da API
  factory AuthData.fromApiResponse(Map<String, dynamic> response) {
    return AuthData(
      accessToken: response['accessToken'] ?? '',
      refreshToken: response['refreshToken'] ?? '',
      expiresIn: response['expiresIn'] ?? 0,
      tokenType: response['tokenType'] ?? 'Bearer',
    );
  }

  @override
  String toString() {
    return 'AuthData(accessToken: ${accessToken.length > 10 ? accessToken.substring(0, 10) : accessToken}..., tokenType: $tokenType, expiresIn: $expiresIn, refreshToken: ${refreshToken.length > 10 ? refreshToken.substring(0, 10) : refreshToken}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthData &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresIn == expiresIn &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        expiresIn.hashCode ^
        tokenType.hashCode;
  }
}
