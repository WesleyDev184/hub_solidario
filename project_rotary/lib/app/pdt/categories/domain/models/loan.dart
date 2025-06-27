class Loan {
  final String id;
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final String reason;
  final DateTime createdAt;
  final DateTime? returnedAt;

  Loan({
    required this.id,
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    required this.reason,
    required this.createdAt,
    this.returnedAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      applicantId: json['applicantId'],
      responsibleId: json['responsibleId'],
      itemId: json['itemId'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
      returnedAt:
          json['returnedAt'] != null
              ? DateTime.parse(json['returnedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantId': applicantId,
      'responsibleId': responsibleId,
      'itemId': itemId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'returnedAt': returnedAt?.toIso8601String(),
    };
  }
}
