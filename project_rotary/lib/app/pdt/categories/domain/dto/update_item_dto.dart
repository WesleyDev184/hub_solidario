class UpdateItemDTO {
  final int? categoryId;
  final int? serialCode;
  final String? stockId;
  final String? imageUrl;

  UpdateItemDTO({
    this.categoryId,
    this.serialCode,
    this.stockId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (categoryId != null) data['categoryId'] = categoryId;
    if (serialCode != null) data['serialCode'] = serialCode;
    if (stockId != null) data['stockId'] = stockId;
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    return data;
  }

  /// Verifica se o DTO está vazio (sem alterações)
  bool get isEmpty =>
      categoryId == null &&
      serialCode == null &&
      stockId == null &&
      imageUrl == null;

  /// Verifica se o DTO contém dados válidos para atualização
  bool get isValid {
    if (isEmpty) return false;

    if (categoryId != null && categoryId! <= 0) return false;
    if (serialCode != null && serialCode! <= 0) return false;
    if (stockId != null && stockId!.trim().isEmpty) return false;
    if (imageUrl != null && imageUrl!.trim().isEmpty) return false;

    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateItemDTO &&
          categoryId == other.categoryId &&
          serialCode == other.serialCode &&
          stockId == other.stockId &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      serialCode.hashCode ^
      stockId.hashCode ^
      imageUrl.hashCode;

  @override
  String toString() =>
      'UpdateItemDTO(categoryId: $categoryId, serialCode: $serialCode, stockId: $stockId, imageUrl: $imageUrl)';
}
