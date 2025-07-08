import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/api/auth/models/auth_models.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';

/// Modelo de Loan (Empréstimo)
class Loan {
  final String id;
  final String? reason;
  final bool isActive;
  final DateTime? returnDate;
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Objetos relacionados (quando carregados da API)
  final Applicant? applicant;
  final Item? item;
  final User? responsible;

  const Loan({
    required this.id,
    this.reason,
    required this.isActive,
    this.returnDate,
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    required this.createdAt,
    this.updatedAt,
    this.applicant,
    this.item,
    this.responsible,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      reason: json['reason'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      returnDate:
          json['returnDate'] != null
              ? DateTime.parse(json['returnDate'] as String)
              : null,
      applicantId:
          json['applicantId'] as String? ??
          json['applicant']?['id'] as String? ??
          '',
      responsibleId:
          json['responsibleId'] as String? ??
          json['responsible']?['id'] as String? ??
          '',
      itemId: json['itemId'] as String? ?? json['item']?['id'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      applicant:
          json['applicant'] != null
              ? Applicant.fromJson(json['applicant'] as Map<String, dynamic>)
              : null,
      item:
          json['item'] != null
              ? Item.fromJson(json['item'] as Map<String, dynamic>)
              : null,
      responsible:
          json['responsible'] != null
              ? User.fromJson(json['responsible'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'isActive': isActive,
      'returnDate': returnDate?.toIso8601String(),
      'applicantId': applicantId,
      'responsibleId': responsibleId,
      'itemId': itemId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (applicant != null) 'applicant': applicant!.toJson(),
      if (item != null) 'item': item!.toJson(),
      if (responsible != null) 'responsible': responsible!.toJson(),
    };
  }

  /// Verifica se o empréstimo está ativo
  bool get isActiveLoan => isActive;

  /// Verifica se o empréstimo foi retornado
  bool get isReturned => !isActive || returnDate != null;

  /// Verifica se o empréstimo está em atraso (mais de 30 dias)
  bool get isOverdue {
    if (!isActive) return false;
    final daysSinceCreated = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreated > 30;
  }

  /// Número de dias desde a criação do empréstimo
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;

  /// Número de dias até o retorno (se houver data de retorno definida)
  int? get daysUntilReturn {
    if (returnDate == null) return null;
    return returnDate!.difference(DateTime.now()).inDays;
  }

  /// Nome do aplicant (se disponível)
  String? get applicantName => applicant?.name;

  /// Nome do responsável (se disponível)
  String? get responsibleName => responsible?.name;

  /// Serial code do item (se disponível)
  int? get itemSerialCode => item?.seriaCode;

  Loan copyWith({
    String? id,
    String? reason,
    bool? isActive,
    DateTime? returnDate,
    String? applicantId,
    String? responsibleId,
    String? itemId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Applicant? applicant,
    Item? item,
    User? responsible,
  }) {
    return Loan(
      id: id ?? this.id,
      reason: reason ?? this.reason,
      isActive: isActive ?? this.isActive,
      returnDate: returnDate ?? this.returnDate,
      applicantId: applicantId ?? this.applicantId,
      responsibleId: responsibleId ?? this.responsibleId,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicant: applicant ?? this.applicant,
      item: item ?? this.item,
      responsible: responsible ?? this.responsible,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Loan && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Loan{id: $id, reason: $reason, isActive: $isActive, applicantId: $applicantId, itemId: $itemId}';
  }
}

/// Modelo temporário para User (pode ser removido quando o módulo auth estiver completo)
// === REQUEST MODELS ===

/// Request para criar um loan
class CreateLoanRequest {
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final String? reason;

  const CreateLoanRequest({
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'applicantId': applicantId,
      'responsibleId': responsibleId,
      'itemId': itemId,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
    };
  }

  @override
  String toString() {
    return 'CreateLoanRequest{applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, reason: $reason}';
  }
}

/// Request para atualizar um loan
class UpdateLoanRequest {
  final String? reason;
  final bool? isActive;

  const UpdateLoanRequest({this.reason, this.isActive});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (reason != null) json['reason'] = reason;
    if (isActive != null) json['isActive'] = isActive;
    return json;
  }

  bool get isEmpty => reason == null && isActive == null;

  @override
  String toString() {
    return 'UpdateLoanRequest{reason: $reason, isActive: $isActive}';
  }
}

// === RESPONSE MODELS ===

/// Response para operações de loan
class LoanResponse {
  final bool success;
  final Loan? data;
  final String? message;

  const LoanResponse({required this.success, this.data, this.message});

  factory LoanResponse.fromJson(Map<String, dynamic> json) {
    return LoanResponse(
      success: json['success'] as bool? ?? false,
      data:
          json['data'] != null
              ? Loan.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.toJson(),
      if (message != null) 'message': message,
    };
  }
}

/// Response para listas de loans
class LoansListResponse {
  final bool success;
  final int count;
  final List<Loan> data;
  final String? message;

  const LoansListResponse({
    required this.success,
    required this.count,
    required this.data,
    this.message,
  });

  factory LoansListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LoansListResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? dataList.length,
      data:
          dataList
              .map((item) => Loan.fromJson(item as Map<String, dynamic>))
              .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((loan) => loan.toJson()).toList(),
      if (message != null) 'message': message,
    };
  }
}

// === FILTROS ===

/// Filtros para busca de loans
class LoanFilters {
  final String? applicantId;
  final String? responsibleId;
  final String? itemId;
  final bool? isActive;
  final String? reason;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final DateTime? returnAfter;
  final DateTime? returnBefore;
  final bool? isOverdue;

  const LoanFilters({
    this.applicantId,
    this.responsibleId,
    this.itemId,
    this.isActive,
    this.reason,
    this.createdAfter,
    this.createdBefore,
    this.returnAfter,
    this.returnBefore,
    this.isOverdue,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (applicantId != null) params['applicantId'] = applicantId!;
    if (responsibleId != null) params['responsibleId'] = responsibleId!;
    if (itemId != null) params['itemId'] = itemId!;
    if (isActive != null) params['isActive'] = isActive.toString();
    if (reason != null && reason!.isNotEmpty) params['reason'] = reason!;
    if (createdAfter != null) {
      params['createdAfter'] = createdAfter!.toIso8601String();
    }
    if (createdBefore != null) {
      params['createdBefore'] = createdBefore!.toIso8601String();
    }
    if (returnAfter != null) {
      params['returnAfter'] = returnAfter!.toIso8601String();
    }
    if (returnBefore != null) {
      params['returnBefore'] = returnBefore!.toIso8601String();
    }
    if (isOverdue != null) params['isOverdue'] = isOverdue.toString();

    return params;
  }

  bool get isEmpty =>
      applicantId == null &&
      responsibleId == null &&
      itemId == null &&
      isActive == null &&
      (reason == null || reason!.isEmpty) &&
      createdAfter == null &&
      createdBefore == null &&
      returnAfter == null &&
      returnBefore == null &&
      isOverdue == null;

  @override
  String toString() {
    return 'LoanFilters{applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, isActive: $isActive, reason: $reason}';
  }
}
