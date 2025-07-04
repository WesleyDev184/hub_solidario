class CreateItemDTO {
  final int serialCode; // Código serial do item
  final String stockId; // UUID da categoria/stock

  CreateItemDTO({required this.serialCode, required this.stockId});

  Map<String, dynamic> toJson() {
    return {
      'seriaCode': serialCode, // API espera 'seriaCode' (sem 'l')
      'stockId': stockId,
    };
  }

  /// Verifica se o DTO contém dados válidos
  bool get isValid => serialCode > 0 && stockId.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateItemDTO &&
          serialCode == other.serialCode &&
          stockId == other.stockId;

  @override
  int get hashCode => serialCode.hashCode ^ stockId.hashCode;

  @override
  String toString() =>
      'CreateItemDTO(serialCode: $serialCode, stockId: $stockId)';
}
