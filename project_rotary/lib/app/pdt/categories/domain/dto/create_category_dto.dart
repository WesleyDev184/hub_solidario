class CreateCategoryDTO {
  final String title;
  final String orthopedicBankId;

  CreateCategoryDTO({required this.title, required this.orthopedicBankId});

  Map<String, dynamic> toJson() {
    return {'title': title, 'orthopedicBankId': orthopedicBankId};
  }

  /// Verifica se o DTO contém dados válidos
  bool get isValid =>
      title.trim().isNotEmpty && orthopedicBankId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCategoryDTO &&
          title == other.title &&
          orthopedicBankId == other.orthopedicBankId;

  @override
  int get hashCode => title.hashCode ^ orthopedicBankId.hashCode;

  @override
  String toString() =>
      'CreateCategoryDTO(title: $title, orthopedicBankId: $orthopedicBankId)';
}
