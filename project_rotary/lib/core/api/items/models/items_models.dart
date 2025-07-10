/// Enum para status de itens
enum ItemStatus {
  maintenance('MAINTENANCE'),
  available('AVAILABLE'),
  unavailable('UNAVAILABLE'),
  lost('LOST'),
  donated('DONATED');

  const ItemStatus(this.value);
  final String value;

  /// Converte string para enum
  static ItemStatus fromString(String value) {
    return ItemStatus.values.firstWhere(
      (status) => status.value == value || value.contains(status.value),
      orElse: () => ItemStatus.available,
    );
  }

  /// Descrição amigável do status
  String get description {
    switch (this) {
      case ItemStatus.maintenance:
        return 'Em manutenção - O item está em manutenção e não pode ser usado';
      case ItemStatus.available:
        return 'Disponível - O item está disponível para uso';
      case ItemStatus.unavailable:
        return 'Indisponível - O item está temporariamente indisponível';
      case ItemStatus.lost:
        return 'Perdido - O item foi perdido e não pode ser recuperado';
      case ItemStatus.donated:
        return 'Doado - O item foi doado e não faz mais parte do inventário';
    }
  }

  /// Indica se o item está disponível para empréstimo
  bool get isAvailableForLoan => this == ItemStatus.available;
}

/// Modelo de Item
class Item {
  final String id;
  final int serialCode;
  final ItemStatus status;
  final String stockId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.serialCode,
    required this.status,
    required this.stockId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    try {
      return Item(
        id: json['id']?.toString() ?? '',
        serialCode: (json['serialCode'] ?? json['seriaCode'] ?? 0) as int,
        status: ItemStatus.fromString(
          json['status']?.toString() ?? 'AVAILABLE',
        ),
        stockId: json['stockId']?.toString() ?? '',
        createdAt:
            json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : DateTime.now(),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
      );
    } catch (e) {
      throw Exception('Erro ao processar dados do item: $e. JSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialCode': serialCode,
      'status': status.value,
      'stockId': stockId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Verifica se o item está disponível para empréstimo
  bool get isAvailableForLoan => status.isAvailableForLoan;

  /// Verifica se o item precisa de manutenção
  bool get needsMaintenance => status == ItemStatus.maintenance;

  /// Verifica se o item está perdido ou doado
  bool get isUnavailable =>
      status == ItemStatus.lost || status == ItemStatus.donated;

  Item copyWith({
    String? id,
    int? serialCode,
    ItemStatus? status,
    String? stockId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      serialCode: serialCode ?? this.serialCode,
      status: status ?? this.status,
      stockId: stockId ?? this.stockId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item(id: $id, serialCode: $serialCode, status: ${status.value})';
  }
}

/// Request para criar um novo item
class CreateItemRequest {
  final int serialCode;
  final String stockId;

  const CreateItemRequest({required this.serialCode, required this.stockId});

  Map<String, dynamic> toJson() {
    return {'seriaCode': serialCode, 'stockId': stockId};
  }

  @override
  String toString() {
    return 'CreateItemRequest(serialCode: $serialCode, stockId: $stockId)';
  }
}

/// Request para atualizar um item existente
class UpdateItemRequest {
  final int? serialCode;
  final ItemStatus? status;

  const UpdateItemRequest({this.serialCode, this.status});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (serialCode != null) data['seriaCode'] = serialCode;
    if (status != null) data['status'] = status!.value;

    return data;
  }

  bool get hasChanges => serialCode != null || status != null;

  @override
  String toString() {
    return 'UpdateItemRequest(serialCode: $serialCode, status: ${status?.value})';
  }
}

/// Response de operações com items
class ItemResponse {
  final bool success;
  final Item? data;
  final String? message;

  const ItemResponse({required this.success, this.data, this.message});

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      success: json['success'] as bool? ?? false,
      data:
          json['data'] != null
              ? Item.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }
}

/// Response de lista de items
class ItemListResponse {
  final bool success;
  final int count;
  final List<Item> data;
  final String? message;

  const ItemListResponse({
    required this.success,
    required this.count,
    required this.data,
    this.message,
  });

  factory ItemListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final items =
        dataList
            .map((item) => Item.fromJson(item as Map<String, dynamic>))
            .toList();

    return ItemListResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? items.length,
      data: items,
      message: json['message'] as String?,
    );
  }
}

/// Response de operações de atualização
class UpdateItemResponse {
  final bool success;
  final Item? data;
  final String? message;

  const UpdateItemResponse({required this.success, this.data, this.message});

  factory UpdateItemResponse.fromJson(Map<String, dynamic> json) {
    return UpdateItemResponse(
      success: json['success'] as bool? ?? false,
      data:
          json['data'] != null
              ? Item.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }
}

/// Response de operações de deleção
class DeleteItemResponse {
  final bool success;
  final String? message;

  const DeleteItemResponse({required this.success, this.message});

  factory DeleteItemResponse.fromJson(Map<String, dynamic> json) {
    return DeleteItemResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Resposta da criação de item
class CreateItemResponse {
  final bool success;
  final String? message;
  final Item? data;

  const CreateItemResponse({required this.success, this.message, this.data});

  factory CreateItemResponse.fromJson(Map<String, dynamic> json) {
    return CreateItemResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data:
          json['data'] != null
              ? Item.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }
}

/// Filtros para busca de items
class ItemFilters {
  final ItemStatus? status;
  final String? stockId;
  final int? minSerialCode;
  final int? maxSerialCode;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const ItemFilters({
    this.status,
    this.stockId,
    this.minSerialCode,
    this.maxSerialCode,
    this.createdAfter,
    this.createdBefore,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (status != null) params['status'] = status!.value;
    if (stockId != null) params['stockId'] = stockId!;
    if (minSerialCode != null)
      params['minSerialCode'] = minSerialCode.toString();
    if (maxSerialCode != null)
      params['maxSerialCode'] = maxSerialCode.toString();
    if (createdAfter != null)
      params['createdAfter'] = createdAfter!.toIso8601String();
    if (createdBefore != null)
      params['createdBefore'] = createdBefore!.toIso8601String();

    return params;
  }

  bool get hasFilters =>
      status != null ||
      stockId != null ||
      minSerialCode != null ||
      maxSerialCode != null ||
      createdAfter != null ||
      createdBefore != null;
}
