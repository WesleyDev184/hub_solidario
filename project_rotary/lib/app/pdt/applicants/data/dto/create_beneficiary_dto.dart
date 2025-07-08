class CreateBeneficiaryDTO {
  final String name;
  final String cpf;
  final String email;
  final String phoneNumber;
  final String address;
  final String applicantId;

  const CreateBeneficiaryDTO({
    required this.name,
    required this.cpf,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.applicantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'applicantId': applicantId,
    };
  }

  @override
  String toString() {
    return 'CreateBeneficiaryDTO(${toJson()})';
  }
}
