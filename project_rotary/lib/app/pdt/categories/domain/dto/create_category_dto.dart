class CreateCategoryDTO {
  final String title;
  final String orthopedicBankId;

  CreateCategoryDTO({required this.title, required this.orthopedicBankId});

  Map<String, dynamic> toJson() {
    return {'title': title, 'orthopedicBankId': orthopedicBankId};
  }
}
