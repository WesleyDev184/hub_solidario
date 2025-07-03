class Beneficiary {
  final String id;
  final String name;
  final String cpf;
  final String email;
  final String phoneNumber;
  final String address;
  final String applicantId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.applicantId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      name: json['name'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
      applicantId: json['applicantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'applicantId': applicantId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Beneficiary copyWith({
    String? id,
    String? name,
    String? cpf,
    String? email,
    String? phoneNumber,
    String? address,
    String? applicantId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      applicantId: applicantId ?? this.applicantId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Beneficiary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Beneficiary(id: $id, name: $name, applicantId: $applicantId)';
  }
}
