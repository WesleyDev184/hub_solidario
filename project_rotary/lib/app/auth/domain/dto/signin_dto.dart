/// DTO para login seguindo RequestLoginUserDto da API.
/// Segue os princípios de Clean Architecture implementados em loans, applicants e categories.
class SignInDTO {
  final String email;
  final String password;

  SignInDTO({required this.email, required this.password});

  /// Converte para o formato esperado pela API
  Map<String, dynamic> toApiRequest() {
    return {'email': email, 'password': password};
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  String toString() {
    return 'SignInDTO(email: $email)';
  }
}
