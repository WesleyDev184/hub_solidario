class UpdateLoanDTO {
  final String? reason;
  final bool? isActive;
  final DateTime? returnDate;

  UpdateLoanDTO({this.reason, this.isActive, this.returnDate});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (reason != null) json['reason'] = reason;
    if (isActive != null) json['isActive'] = isActive;
    if (returnDate != null) json['returnDate'] = returnDate!.toIso8601String();

    return json;
  }
}
