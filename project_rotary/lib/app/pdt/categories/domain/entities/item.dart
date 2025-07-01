import 'package:flutter/foundation.dart';

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
    try {
      // Extração do serialCode - API retorna como 'seriaCode' (sem 'l')
      dynamic serialCodeValue =
          json['serialCode'] ?? json['serial_code'] ?? json['seriaCode'];
      int serialCode = 0;

      if (serialCodeValue != null) {
        if (serialCodeValue is int) {
          serialCode = serialCodeValue;
        } else if (serialCodeValue is double) {
          serialCode = serialCodeValue.toInt();
        } else if (serialCodeValue is String) {
          serialCode = int.tryParse(serialCodeValue) ?? 0;
        }
      }

      return Item(
        id: json['id']?.toString() ?? '',
        serialCode: serialCode,
        stockId:
            json['stockId']?.toString() ??
            json['stock_id']?.toString() ??
            '', // Campo obrigatório mas pode estar ausente
        imageUrl:
            json['imageUrl']?.toString() ??
            json['image_url']?.toString() ??
            '', // Campo opcional
        status: json['status']?.toString() ?? 'AVAILABLE',
        categoryId:
            json['categoryId']?.toString() ??
            json['category_id']?.toString() ??
            '', // Campo obrigatório mas pode estar ausente
        createdAt:
            json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ??
                    DateTime.now()
                : json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString()) ??
                    DateTime.now()
                : DateTime.now(),
        updatedAt:
            json['updatedAt'] != null
                ? DateTime.tryParse(json['updatedAt'].toString())
                : json['updated_at'] != null
                ? DateTime.tryParse(json['updated_at'].toString())
                : null,
      );
    } catch (e) {
      debugPrint('Item.fromJson - Error: $e');
      debugPrint('Item.fromJson - JSON was: $json');
      rethrow;
    }
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
