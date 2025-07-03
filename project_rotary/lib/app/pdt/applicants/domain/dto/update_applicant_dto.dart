class UpdateApplicantDTO {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final bool? isBeneficiary;

  const UpdateApplicantDTO({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    this.isBeneficiary,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (cpf != null) data['cpf'] = cpf;
    if (email != null) data['email'] = email;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address;
    if (isBeneficiary != null) data['isBeneficiary'] = isBeneficiary;

    return data;
  }

  bool get isEmpty =>
      name == null &&
      cpf == null &&
      email == null &&
      phoneNumber == null &&
      address == null &&
      isBeneficiary == null;
}
