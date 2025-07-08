class CreateApplicantDTO {
  final String name;
  final String cpf;
  final String email;
  final String phoneNumber;
  final String? address;
  final bool isBeneficiary;

  const CreateApplicantDTO({
    required this.name,
    required this.cpf,
    required this.email,
    required this.phoneNumber,
    this.address,
    required this.isBeneficiary,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'isBeneficiary': isBeneficiary,
    };
  }

  @override
  String toString() {
    return 'CreateApplicantDTO(${toJson()})';
  }
}
