import 'package:project_rotary/app/auth/data/entities/orthopedic_bank.dart';

/// Entidade que representa um usuário no sistema.
/// Segue os princípios de Clean Architecture implementados em loans, applicants e categories.
class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final OrthopedicBank?
  orthopedicBank; // Banco ortopédico relacionado (se disponível)
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.orthopedicBank,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? orthopedicBankId,
    OrthopedicBank? orthopedicBank,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      orthopedicBank: orthopedicBank ?? this.orthopedicBank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'orthopedicBank': orthopedicBank?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      orthopedicBank:
          map['orthopedicBank'] != null
              ? OrthopedicBank.fromMap(
                map['orthopedicBank'] as Map<String, dynamic>,
              )
              : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, orthopedicBank: $orthopedicBank, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.orthopedicBank == orthopedicBank &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        orthopedicBank.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
