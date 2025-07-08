class CreateLoanDTO {
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final String reason;

  CreateLoanDTO({
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      'responsibleId': responsibleId,
      'itemId': itemId,
      'reason': reason,
    };
  }

  /// Verifica se o DTO contém dados válidos
  bool get isValid =>
      applicantId.trim().isNotEmpty &&
      responsibleId.trim().isNotEmpty &&
      itemId.trim().isNotEmpty &&
      reason.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLoanDTO &&
          applicantId == other.applicantId &&
          responsibleId == other.responsibleId &&
          itemId == other.itemId &&
          reason == other.reason;

  @override
  int get hashCode =>
      applicantId.hashCode ^
      responsibleId.hashCode ^
      itemId.hashCode ^
      reason.hashCode;

  @override
  String toString() =>
      'CreateLoanDTO(applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, reason: $reason)';
}
