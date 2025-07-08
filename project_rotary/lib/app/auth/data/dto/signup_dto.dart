/// DTO para criação de usuário seguindo RequestCreateUserDto da API.
/// Segue os princípios de Clean Architecture implementados em loans, applicants e categories.
class SignUpDTO {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;
  final String orthopedicBankId;

  SignUpDTO({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
    required this.orthopedicBankId,
  });

  /// Converte para o formato esperado pela API
  Map<String, dynamic> toApiRequest() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'orthopedicBankId': orthopedicBankId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
      'orthopedicBankId': orthopedicBankId,
    };
  }

  @override
  String toString() {
    return 'SignUpDTO(name: $name, email: $email, phoneNumber: $phoneNumber, orthopedicBankId: $orthopedicBankId)';
  }
}
