import 'package:project_rotary/core/api/applicants/models/applicants_models.dart';
import 'package:project_rotary/core/api/auth/models/auth_models.dart';
import 'package:project_rotary/core/api/items/models/items_models.dart';

/// Modelo de Loan (Empréstimo) - Versão completa
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
    try {
      return Loan(
        id: json['id'] as String,
        reason: json['reason'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        returnDate:
            json['returnDate'] != null
                ? DateTime.parse(json['returnDate'] as String)
                : null,
        applicantId: _extractId(json, 'applicant', 'applicantId'),
        responsibleId: _extractId(json, 'responsible', 'responsibleId'),
        itemId: _extractId(json, 'item', 'itemId'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
        applicant:
            json['applicant'] != null &&
                    json['applicant'] is Map<String, dynamic>
                ? Applicant.fromJson(json['applicant'] as Map<String, dynamic>)
                : null,
        item:
            json['item'] != null && json['item'] is Map<String, dynamic>
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

  /// Extrai o ID de um campo que pode ser string, número ou objeto
  static String _extractId(
    Map<String, dynamic> json,
    String fieldName,
    String idFieldName,
  ) {
    final directId = json[idFieldName];
    if (directId != null) {
      return directId.toString();
    }

    final fieldValue = json[fieldName];
    if (fieldValue == null) return '';

    if (fieldValue is Map<String, dynamic>) {
      return fieldValue['id']?.toString() ?? '';
    }

    return fieldValue.toString();
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
    return 'Loan{id: $id, reason: $reason, isActive: $isActive, applicantId: $applicantId, responsibleId: $responsibleId, itemId: $itemId, createdAt: $createdAt, returnDate: $returnDate}';
  }
}

/// Modelo simplificado de Loan para listagem
/// Otimizado para diferentes formatos de resposta da API
class LoanListItem {
  final String id;
  final String? reason;
  final bool isActive;
  final DateTime? returnDate;
  final String applicantId;
  final String responsibleId;
  final String itemId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Campos derivados úteis para listagem
  final String? applicantName;
  final String? responsibleName;
  final int? itemSerialCode;

  const LoanListItem({
    required this.id,
    this.reason,
    required this.isActive,
    this.returnDate,
    required this.applicantId,
    required this.responsibleId,
    required this.itemId,
    required this.createdAt,
    this.updatedAt,
    this.applicantName,
    this.responsibleName,
    this.itemSerialCode,
  });

  /// Cria LoanListItem a partir de um Loan completo
  factory LoanListItem.fromLoan(Loan loan) {
    return LoanListItem(
      id: loan.id,
      reason: loan.reason,
      isActive: loan.isActive,
      returnDate: loan.returnDate,
      applicantId: loan.applicantId,
      responsibleId: loan.responsibleId,
      itemId: loan.itemId,
      createdAt: loan.createdAt,
      updatedAt: loan.updatedAt,
      applicantName: loan.applicant?.name,
      responsibleName: loan.responsible?.name,
      itemSerialCode: loan.item?.serialCode,
    );
  }

  /// Formato de LISTA: valores simples
  /// Exemplo: "applicant": "John Doe", "item": 12345
  factory LoanListItem.fromListJson(Map<String, dynamic> json) {
    try {
      return LoanListItem(
        id: json['id'] as String,
        reason: json['reason'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        returnDate:
            json['returnDate'] != null
                ? DateTime.parse(json['returnDate'] as String)
                : null,
        applicantId: '', // No formato de lista, não temos os IDs separados
        responsibleId: '',
        itemId: '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
        // No formato de lista, os campos vem como valores simples
        applicantName: json['applicant'] as String?,
        responsibleName: json['responsible'] as String?,
        itemSerialCode: json['item'] as int?,
      );
    } catch (e) {
      throw Exception('Erro ao processar LoanListItem (formato lista): $e');
    }
  }

  /// Formato INDIVIDUAL: objetos completos
  /// Exemplo: "applicant": {"id": "...", "name": "John Doe", ...}
  factory LoanListItem.fromDetailJson(Map<String, dynamic> json) {
    try {
      final applicantData = json['applicant'] as Map<String, dynamic>?;
      final responsibleData = json['responsible'] as Map<String, dynamic>?;
      final itemData = json['item'] as Map<String, dynamic>?;

      return LoanListItem(
        id: json['id'] as String,
        reason: json['reason'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        returnDate:
            json['returnDate'] != null
                ? DateTime.parse(json['returnDate'] as String)
                : null,
        applicantId: applicantData?['id'] as String? ?? '',
        responsibleId: responsibleData?['id'] as String? ?? '',
        itemId: itemData?['id'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
        applicantName: applicantData?['name'] as String?,
        responsibleName: responsibleData?['name'] as String?,
        itemSerialCode: itemData?['seriaCode'] as int?, // API usa 'seriaCode'
      );
    } catch (e) {
      throw Exception('Erro ao processar LoanListItem (formato detalhado): $e');
    }
  }

  /// Detecta automaticamente o formato e cria o LoanListItem apropriado
  factory LoanListItem.fromJson(Map<String, dynamic> json) {
    // Detecta se é formato de lista ou individual
    final applicantValue = json['applicant'];
    final itemValue = json['item'];
    final responsibleValue = json['responsible'];

    // Se os campos são objetos, é formato individual
    if (applicantValue is Map<String, dynamic> ||
        itemValue is Map<String, dynamic> ||
        responsibleValue is Map<String, dynamic>) {
      return LoanListItem.fromDetailJson(json);
    }

    // Se os campos são valores simples, é formato de lista
    return LoanListItem.fromListJson(json);
  }

  /// Converte para JSON
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
      if (applicantName != null) 'applicantName': applicantName,
      if (responsibleName != null) 'responsibleName': responsibleName,
      if (itemSerialCode != null) 'itemSerialCode': itemSerialCode,
      // Campos derivados úteis
      'daysSinceCreated': daysSinceCreated,
      'isOverdue': isOverdue,
      'isReturned': isReturned,
      'daysUntilReturn': daysUntilReturn,
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

  /// Converte lista de Loans para lista de LoanListItems
  static List<LoanListItem> fromLoanList(List<Loan> loans) {
    return loans.map((loan) => LoanListItem.fromLoan(loan)).toList();
  }

  /// Converte lista de JSON para lista de LoanListItems
  static List<LoanListItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => LoanListItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converte especificamente lista de formato simples
  static List<LoanListItem> fromListJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => LoanListItem.fromListJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converte especificamente lista de formato detalhado
  static List<LoanListItem> fromDetailJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => LoanListItem.fromDetailJson(json as Map<String, dynamic>),
        )
        .toList();
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
    return 'LoanListItem{id: $id, reason: $reason, isActive: $isActive, applicantName: $applicantName, responsibleName: $responsibleName, itemSerialCode: $itemSerialCode}';
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

/// Response para listas de loans (formato completo)
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

  /// Converte para JSON com apenas dados essenciais para listagem
  Map<String, dynamic> toListJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((loan) => loan.toListItem().toJson()).toList(),
      if (message != null) 'message': message,
    };
  }
}

/// Response especializada para listas de LoanListItems
class LoanListItemsResponse {
  final bool success;
  final int count;
  final List<LoanListItem> data;
  final String? message;

  const LoanListItemsResponse({
    required this.success,
    required this.count,
    required this.data,
    this.message,
  });

  /// Para formato de lista (valores simples)
  factory LoanListItemsResponse.fromListJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LoanListItemsResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? dataList.length,
      data: LoanListItem.fromListJsonList(dataList),
      message: json['message'] as String?,
    );
  }

  /// Para formato detalhado (objetos completos)
  factory LoanListItemsResponse.fromDetailJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LoanListItemsResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? dataList.length,
      data: LoanListItem.fromDetailJsonList(dataList),
      message: json['message'] as String?,
    );
  }

  /// Detecta automaticamente o formato
  factory LoanListItemsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return LoanListItemsResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? dataList.length,
      data: LoanListItem.fromJsonList(dataList),
      message: json['message'] as String?,
    );
  }

  /// Cria a partir de LoansListResponse
  factory LoanListItemsResponse.fromLoansListResponse(
    LoansListResponse response,
  ) {
    return LoanListItemsResponse(
      success: response.success,
      count: response.count,
      data: LoanListItem.fromLoanList(response.data),
      message: response.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'data': data.map((item) => item.toJson()).toList(),
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
