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
}
