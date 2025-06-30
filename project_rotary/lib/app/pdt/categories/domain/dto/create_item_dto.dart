class CreateItemDTO {
  final int categoryId;
  final int serialCode;
  final String stockId;
  final String imageUrl;

  CreateItemDTO({
    required this.categoryId,
    required this.serialCode,
    required this.stockId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'serialCode': serialCode,
      'stockId': stockId,
      'imageUrl': imageUrl,
    };
  }

  /// Verifica se o DTO contém dados válidos
  bool get isValid =>
      categoryId > 0 &&
      serialCode > 0 &&
      stockId.trim().isNotEmpty &&
      imageUrl.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateItemDTO &&
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
      'CreateItemDTO(categoryId: $categoryId, serialCode: $serialCode, stockId: $stockId, imageUrl: $imageUrl)';
}
