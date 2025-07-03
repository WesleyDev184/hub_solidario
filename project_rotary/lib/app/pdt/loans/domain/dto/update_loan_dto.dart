/// DTO para atualização de empréstimos existentes.
/// Segue o padrão Clean Architecture implementado em applicants e categories.
class UpdateLoanDTO {
  final String? reason;
  final bool? isActive;
  final DateTime? returnDate;

  const UpdateLoanDTO({this.reason, this.isActive, this.returnDate});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (reason != null) json['reason'] = reason;
    if (isActive != null) json['isActive'] = isActive;
    if (returnDate != null) json['returnDate'] = returnDate!.toIso8601String();

    return json;
  }

  factory UpdateLoanDTO.fromJson(Map<String, dynamic> json) {
    return UpdateLoanDTO(
      reason: json['reason'] as String?,
      isActive: json['isActive'] as bool?,
      returnDate:
          json['returnDate'] != null
              ? DateTime.parse(json['returnDate'] as String)
              : null,
    );
  }

  @override
  String toString() {
    return 'UpdateLoanDTO(reason: $reason, isActive: $isActive, returnDate: $returnDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdateLoanDTO &&
        other.reason == reason &&
        other.isActive == isActive &&
        other.returnDate == returnDate;
  }

  @override
  int get hashCode {
    return reason.hashCode ^ isActive.hashCode ^ returnDate.hashCode;
  }
}
