class Item {
  final String id;
  final int serialCode;
  final String stockId;
  final String imageUrl;
  final String status;
  final String categoryId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Item({
    required this.id,
    required this.serialCode,
    required this.stockId,
    required this.imageUrl,
    required this.status,
    required this.categoryId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      serialCode: json['serialCode'] as int,
      stockId: json['stockId'] as String,
      imageUrl: json['imageUrl'] as String,
      status: json['status'] as String,
      categoryId: json['categoryId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialCode': serialCode,
      'stockId': stockId,
      'imageUrl': imageUrl,
      'status': status,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Item copyWith({
    String? id,
    int? serialCode,
    String? stockId,
    String? imageUrl,
    String? status,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      serialCode: serialCode ?? this.serialCode,
      stockId: stockId ?? this.stockId,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
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
    return 'Item(id: $id, serialCode: $serialCode, status: $status)';
  }

  bool get isAvailable => status.toLowerCase() == 'disponível';
  bool get isLoaned => status.toLowerCase() == 'emprestado';
  bool get isMaintenance => status.toLowerCase() == 'manutenção';
}
