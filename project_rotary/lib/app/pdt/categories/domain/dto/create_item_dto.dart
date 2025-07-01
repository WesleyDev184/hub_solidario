class CreateItemDTO {
  final int serialCode; // Agora é serial code apenas
  final String stockId; // UUID da categoria/stock
  final String imageUrl; // URL opcional da imagem

  CreateItemDTO({
    required this.serialCode,
    required this.stockId,
    this.imageUrl = '', // Padrão vazio
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'seriaCode': serialCode, // API espera 'seriaCode' (sem 'l')
      'stockId': stockId,
    };

    // Só adiciona imageUrl se não estiver vazia
    if (imageUrl.trim().isNotEmpty) {
      json['imageUrl'] = imageUrl;
    }

    return json;
  }

  /// Verifica se o DTO contém dados válidos
  bool get isValid => serialCode > 0 && stockId.trim().isNotEmpty;
  // imageUrl não é mais obrigatória

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateItemDTO &&
          serialCode == other.serialCode &&
          stockId == other.stockId &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      serialCode.hashCode ^ stockId.hashCode ^ imageUrl.hashCode;

  @override
  String toString() =>
      'CreateItemDTO(serialCode: $serialCode, stockId: $stockId, imageUrl: $imageUrl)';
}
