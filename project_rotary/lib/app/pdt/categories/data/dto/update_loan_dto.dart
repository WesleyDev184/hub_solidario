class UpdateLoanDTO {
  final String? applicantId;
  final String? responsibleId;
  final String? itemId;
  final String? reason;
  final DateTime? returnDate;
  final String? status;

  UpdateLoanDTO({
    this.applicantId,
    this.responsibleId,
    this.itemId,
    this.reason,
    this.returnDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (applicantId != null) data['applicantId'] = applicantId;
    if (responsibleId != null) data['responsibleId'] = responsibleId;
    if (itemId != null) data['itemId'] = itemId;
    if (reason != null) data['reason'] = reason;
    if (returnDate != null) data['returnDate'] = returnDate!.toIso8601String();
    if (status != null) data['status'] = status;

    return data;
  }

  /// Verifica se o DTO está vazio (sem alterações)
  bool get isEmpty =>
      applicantId == null &&
      responsibleId == null &&
      itemId == null &&
      reason == null &&
      returnDate == null &&
      status == null;

  /// Verifica se o DTO contém dados válidos para atualização
  bool get isValid {
    if (isEmpty) return false;

    if (applicantId != null && applicantId!.trim().isEmpty) return false;
    if (responsibleId != null && responsibleId!.trim().isEmpty) return false;
    if (itemId != null && itemId!.trim().isEmpty) return false;
    if (reason != null && reason!.trim().isEmpty) return false;
    if (status != null && status!.trim().isEmpty) return false;

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateLoanDTO &&
          applicantId == other.applicantId &&
          responsibleId == other.responsibleId &&
          itemId == other.itemId &&
          reason == other.reason &&
          returnDate == other.returnDate &&
          status == other.status;

  @override
  int get hashCode =>
      applicantId.hashCode ^
      responsibleId.hashCode ^
      itemId.hashCode ^
      reason.hashCode ^
      returnDate.hashCode ^
      status.hashCode;

  @override
  String toString() =>
      'UpdateLoanDTO(applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, reason: $reason, returnDate: $returnDate, status: $status)';
}
