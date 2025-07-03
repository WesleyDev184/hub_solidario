class UpdateBeneficiaryDTO {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;

  const UpdateBeneficiaryDTO({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (cpf != null) data['cpf'] = cpf;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;

    return data;
  }

  @override
  String toString() {
    return 'UpdateBeneficiaryDTO(${toJson()})';
  }
}
