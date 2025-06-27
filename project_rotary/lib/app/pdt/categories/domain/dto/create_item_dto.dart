class CreateItemDTO {
  final int serialCode;
  final String stockId;
  final String imageUrl;

  CreateItemDTO({
    required this.serialCode,
    required this.stockId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {'serialCode': serialCode, 'stockId': stockId, 'imageUrl': imageUrl};
  }
}
