/// DTO para criação de novos empréstimos.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class CreateLoanDTO {
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final String reason;

  const CreateLoanDTO({
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

  factory CreateLoanDTO.fromJson(Map<String, dynamic> json) {
    return CreateLoanDTO(
      applicantId: json['applicantId'] as String,
      responsibleId: json['responsibleId'] as String,
      itemId: json['itemId'] as String,
      reason: json['reason'] as String,
    );
  }

  @override
  String toString() {
    return 'CreateLoanDTO(applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateLoanDTO &&
        other.applicantId == applicantId &&
        other.responsibleId == responsibleId &&
        other.itemId == itemId &&
        other.reason == reason;
  }

  @override
  int get hashCode {
    return applicantId.hashCode ^
        responsibleId.hashCode ^
        itemId.hashCode ^
        reason.hashCode;
  }
}
