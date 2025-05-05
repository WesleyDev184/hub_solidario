// filepath: /home/wesley/www/github/UFMT/tcc/project_rotary/lib/features/auth/domain/dto/signup_dto.dart

class SignUpDTO {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  SignUpDTO({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone, 'password': password};
  }
}
