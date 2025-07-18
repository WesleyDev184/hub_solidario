import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/api/auth/models/auth_models.dart';
import 'package:app/core/api/loans/models/items_models.dart';

/// Modelo de Loan (Empréstimo) - Versão completa
class Loan {
  final String id;
  final String? reason;
  final bool isActive;
  final DateTime? returnDate;
  final DateTime createdAt;

  // Objetos relacionados (quando carregados da API)
  final Applicant? applicant;
  final Item? item;
  final User? responsible;

  const Loan({
    required this.id,
    this.reason,
    required this.isActive,
    this.returnDate,
    required this.createdAt,
    this.applicant,
    this.item,
    this.responsible,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    try {
      return Loan(
        id: json['id'] as String,
        reason: json['reason'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        returnDate: json['returnDate'] != null
            ? DateTime.parse(json['returnDate'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        applicant:
            json['applicant'] != null &&
                json['applicant'] is Map<String, dynamic>
            ? Applicant.fromJson(json['applicant'] as Map<String, dynamic>)
            : null,
        item: json['item'] != null && json['item'] is Map<String, dynamic>
            ? Item.fromJson(json['item'] as Map<String, dynamic>)
            : null,
        responsible:
            json['responsible'] != null &&
                json['responsible'] is Map<String, dynamic>
            ? User.fromJson(json['responsible'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      throw Exception('Erro ao processar resposta dos empréstimos: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'isActive': isActive,
      'returnDate': returnDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
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
    return daysSinceCreated > 90;
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
  int? get itemSerialCode => item?.serialCode;

  /// Converte para LoanListItem (versão simplificada)
  LoanListItem toListItem() {
    return LoanListItem.fromLoan(this);
  }

  Loan copyWith({
    String? id,
    String? reason,
    bool? isActive,
    DateTime? returnDate,
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
      createdAt: createdAt ?? this.createdAt,
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
    return 'Loan{id: $id, reason: $reason, isActive: $isActive, createdAt: $createdAt, returnDate: $returnDate}';
  }
}

/// Modelo simplificado de Loan para listagem
/// Otimizado para diferentes formatos de resposta da API
class LoanListItem {
  final String id;
  final String? reason;
  final bool isActive;
  final DateTime? returnDate;
  final String applicant;
  final String responsible;
  final int item;
  final DateTime createdAt;

  const LoanListItem({
    required this.id,
    this.reason,
    required this.isActive,
    this.returnDate,
    required this.applicant,
    required this.responsible,
    required this.item,
    required this.createdAt,
  });

  /// Cria LoanListItem a partir de um Loan completo
  factory LoanListItem.fromLoan(Loan loan) {
    return LoanListItem(
      id: loan.id,
      reason: loan.reason,
      isActive: loan.isActive,
      returnDate: loan.returnDate,
      createdAt: loan.createdAt,
      applicant: loan.applicant?.name ?? '',
      responsible: loan.responsible?.name ?? '',
      item: loan.item?.serialCode ?? 0,
    );
  }

  String get formattedSerialCode {
    // Formata o serial code para o padrão ####-####
    final code = item.toString().padLeft(8, '0');
    return '${code.substring(0, 4)}-${code.substring(4)}';
  }

  /// Formato de LISTA: valores simples
  /// Exemplo: "applicant": "John Doe", "item": 12345
  factory LoanListItem.fromJson(Map<String, dynamic> json) {
    return LoanListItem(
      id: json['id'] as String,
      reason: json['reason'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      applicant: json['applicant'] as String? ?? '',
      responsible: json['responsible'] as String? ?? '',
      item: json['item'] as int? ?? 0,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
      'isActive': isActive,
      'returnDate': returnDate?.toIso8601String(),
      'applicant': applicant,
      'responsible': responsible,
      'item': item,
      'createdAt': createdAt.toIso8601String(),
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
    return daysSinceCreated > 90;
  }

  /// Número de dias desde a criação do empréstimo
  int get daysSinceCreated => DateTime.now().difference(createdAt).inDays;

  /// Número de dias até o retorno (se houver data de retorno definida)
  int? get daysUntilReturn {
    if (returnDate == null) return null;
    return returnDate!.difference(DateTime.now()).inDays;
  }

  /// Converte lista de Loans para lista de LoanListItems
  static List<LoanListItem> fromLoanList(List<Loan> loans) {
    return loans.map((loan) => LoanListItem.fromLoan(loan)).toList();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LoanListItem &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LoanListItem{id: $id, reason: $reason, isActive: $isActive, createdAt: $createdAt, applicant: $applicant, responsible: $responsible, item: $item}';
  }
}

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
  final String? returnDate;

  const UpdateLoanRequest({this.reason, this.isActive, this.returnDate});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (reason != null) json['reason'] = reason;
    if (isActive != null) json['isActive'] = isActive;
    if (returnDate != null) json['returnDate'] = returnDate;
    return json;
  }

  bool get isEmpty => reason == null && isActive == null && returnDate == null;

  @override
  String toString() {
    return 'UpdateLoanRequest{reason: $reason, isActive: $isActive}, returnDate: $returnDate';
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
      data: json['data'] != null
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

/// Response para listas de loans (formato completo)
class LoansListResponse {
  final bool success;
  final int count;
  final List<LoanListItem> data;
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
      data: dataList
          .map((item) => LoanListItem.fromJson(item as Map<String, dynamic>))
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
