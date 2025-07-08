/// Entidade Loan seguindo o padrão Clean Architecture.
/// Representa um empréstimo no domínio da aplicação.
class Loan {
  final String id;
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final String reason;
  final DateTime createdAt;
  final DateTime? returnedAt;
  final bool isActive;

  const Loan({
    required this.id,
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    required this.reason,
    required this.createdAt,
    this.returnedAt,
    required this.isActive,
  });

  /// Factory para criar Loan a partir de JSON
  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      applicantId: json['applicantId'] as String,
      responsibleId: json['responsibleId'] as String,
      itemId: json['itemId'] as String,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      returnedAt:
          json['returnedAt'] != null
              ? DateTime.parse(json['returnedAt'] as String)
              : null,
      isActive: json['returnedAt'] == null,
    );
  }

  /// Converte Loan para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantId': applicantId,
      'responsibleId': responsibleId,
      'itemId': itemId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'returnedAt': returnedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Cria uma cópia do Loan com alguns campos alterados
  Loan copyWith({
    String? id,
    String? applicantId,
    String? responsibleId,
    String? itemId,
    String? reason,
    DateTime? createdAt,
    DateTime? returnedAt,
    bool? isActive,
  }) {
    return Loan(
      id: id ?? this.id,
      applicantId: applicantId ?? this.applicantId,
      responsibleId: responsibleId ?? this.responsibleId,
      itemId: itemId ?? this.itemId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      returnedAt: returnedAt ?? this.returnedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Loan(id: $id, applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, reason: $reason, createdAt: $createdAt, returnedAt: $returnedAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Loan &&
        other.id == id &&
        other.applicantId == applicantId &&
        other.responsibleId == responsibleId &&
        other.itemId == itemId &&
        other.reason == reason &&
        other.createdAt == createdAt &&
        other.returnedAt == returnedAt &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        applicantId.hashCode ^
        responsibleId.hashCode ^
        itemId.hashCode ^
        reason.hashCode ^
        createdAt.hashCode ^
        returnedAt.hashCode ^
        isActive.hashCode;
  }
}
