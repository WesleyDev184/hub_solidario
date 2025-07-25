import 'dart:io';
import 'dart:typed_data';

import 'package:app/core/api/stocks/models/items_models.dart';
import 'package:app/core/api/orthopedic_banks/orthopedic_banks.dart';

/// Modelo de Stock
class Stock {
  final String id;
  final String title;
  final String? imageUrl;
  final int maintenanceQtd;
  final int availableQtd;
  final int borrowedQtd;
  final int totalQtd;
  final String orthopedicBankId;
  final OrthopedicBank? orthopedicBank;
  final List<Item>? items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stock({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.maintenanceQtd,
    required this.availableQtd,
    required this.borrowedQtd,
    required this.totalQtd,
    required this.orthopedicBankId,
    this.orthopedicBank,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      maintenanceQtd: json['maintenanceQtd'] as int? ?? 0,
      availableQtd: json['availableQtd'] as int? ?? 0,
      borrowedQtd: json['borrowedQtd'] as int? ?? 0,
      totalQtd: json['totalQtd'] as int? ?? 0,
      orthopedicBankId: json['orthopedicBankId'] as String,
      orthopedicBank: json['orthopedicBank'] != null
          ? OrthopedicBank.fromJson(
              json['orthopedicBank'] as Map<String, dynamic>,
            )
          : null,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
                .map((item) => Item.fromJson(item as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.parse(
              json['createdAt'] as String,
            ), // Fallback para createdAt se updatedAt não estiver presente
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'maintenanceQtd': maintenanceQtd,
      'availableQtd': availableQtd,
      'borrowedQtd': borrowedQtd,
      'totalQtd': totalQtd,
      'orthopedicBankId': orthopedicBankId,
      'orthopedicBank': orthopedicBank?.toJson(),
      'items': items?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Verifica se há itens disponíveis
  bool get hasAvailableItems => availableQtd > 0;

  Stock copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? maintenanceQtd,
    int? availableQtd,
    int? borrowedQtd,
    int? totalQtd,
    String? orthopedicBankId,
    OrthopedicBank? orthopedicBank,
    List<Item>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Stock(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      maintenanceQtd: maintenanceQtd ?? this.maintenanceQtd,
      availableQtd: availableQtd ?? this.availableQtd,
      borrowedQtd: borrowedQtd ?? this.borrowedQtd,
      totalQtd: totalQtd ?? this.totalQtd,
      orthopedicBankId: orthopedicBankId ?? this.orthopedicBankId,
      orthopedicBank: orthopedicBank ?? this.orthopedicBank,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stock && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Stock(id: $id, title: $title, available: $availableQtd)';
  }
}

/// Request para criar um novo stock
class CreateStockRequest {
  final String title;
  final String orthopedicBankId;
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imageFileName;

  const CreateStockRequest({
    required this.title,
    required this.orthopedicBankId,
    this.imageFile,
    this.imageBytes,
    this.imageFileName,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'orthopedicBankId': orthopedicBankId};
  }

  @override
  String toString() {
    return 'CreateStockRequest(title: $title, orthopedicBankId: $orthopedicBankId)';
  }
}

/// Request para atualizar um stock existente
class UpdateStockRequest {
  final String? title;
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imageFileName;
  final int? maintenanceQtd;
  final int? availableQtd;
  final int? borrowedQtd;

  const UpdateStockRequest({
    this.title,
    this.imageFile,
    this.imageBytes,
    this.imageFileName,
    this.maintenanceQtd,
    this.availableQtd,
    this.borrowedQtd,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (title != null) data['title'] = title;
    if (maintenanceQtd != null) data['maintenanceQtd'] = maintenanceQtd;
    if (availableQtd != null) data['availableQtd'] = availableQtd;
    if (borrowedQtd != null) data['borrowedQtd'] = borrowedQtd;

    return data;
  }

  bool get hasImage => imageFile != null || imageBytes != null;

  @override
  String toString() {
    return 'UpdateStockRequest(title: $title, maintenanceQtd: $maintenanceQtd, availableQtd: $availableQtd, borrowedQtd: $borrowedQtd)';
  }
}

/// Response de operações com stocks
class StockResponse {
  final bool success;
  final Stock? data;
  final String? message;

  const StockResponse({required this.success, this.data, this.message});

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? Stock.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Response de lista de stocks
class StockListResponse {
  final bool success;
  final int count;
  final List<Stock> data;
  final String? message;

  const StockListResponse({
    required this.success,
    required this.count,
    required this.data,
    this.message,
  });

  factory StockListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    final stocks = dataList
        .map((item) => Stock.fromJson(item as Map<String, dynamic>))
        .toList();

    return StockListResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? stocks.length,
      data: stocks,
      message: json['message'] as String?,
    );
  }
}

/// Response de operações de criação
class CreateStockResponse {
  final bool success;
  final String? message;
  final String? stockId;

  const CreateStockResponse({
    required this.success,
    this.message,
    this.stockId,
  });

  factory CreateStockResponse.fromJson(Map<String, dynamic> json) {
    return CreateStockResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      stockId: json['data']?['id'] as String?,
    );
  }
}

/// Response de operações de atualização
class UpdateStockResponse {
  final bool success;
  final Stock? data;
  final String? message;

  const UpdateStockResponse({required this.success, this.data, this.message});

  factory UpdateStockResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStockResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? Stock.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Response de operações de deleção
class DeleteStockResponse {
  final bool success;
  final String? message;

  const DeleteStockResponse({required this.success, this.message});

  factory DeleteStockResponse.fromJson(Map<String, dynamic> json) {
    return DeleteStockResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}
