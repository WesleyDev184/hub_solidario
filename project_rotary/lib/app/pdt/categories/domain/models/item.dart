class Item {
  final String id;
  final int serialCode;
  final String stockId;
  final String imageUrl;
  final String status;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.serialCode,
    required this.stockId,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      serialCode: json['serialCode'],
      stockId: json['stockId'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serialCode': serialCode,
      'stockId': stockId,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
