class Applicant {
  final String id;
  final String name;
  final String cpf;
  final String email;
  final String phoneNumber;
  final String? address;
  final bool isBeneficiary;
  final List<String> beneficiaryIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Applicant({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phoneNumber,
    this.address,
    required this.isBeneficiary,
    required this.beneficiaryIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id'] as String,
      name: json['name'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String?,
      isBeneficiary: json['isBeneficiary'] as bool,
      beneficiaryIds: List<String>.from(json['beneficiaryIds'] ?? []),
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
      'isBeneficiary': isBeneficiary,
      'beneficiaryIds': beneficiaryIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Applicant copyWith({
    String? id,
    String? name,
    String? cpf,
    String? email,
    String? phoneNumber,
    String? address,
    bool? isBeneficiary,
    List<String>? beneficiaryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Applicant(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isBeneficiary: isBeneficiary ?? this.isBeneficiary,
      beneficiaryIds: beneficiaryIds ?? this.beneficiaryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Applicant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Applicant(id: $id, name: $name, cpf: $cpf)';
  }
}
