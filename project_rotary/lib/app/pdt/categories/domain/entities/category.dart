class Category {
  final String id;
  final String title;
  final Map<String, dynamic> orthopedicBank;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final int? availableQtd;
  final int? borrowedQtd;
  final int? maintenanceQtd;

  const Category({
    required this.id,
    required this.title,
    required this.orthopedicBank,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.availableQtd,
    this.borrowedQtd,
    this.maintenanceQtd,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      orthopedicBank: json['orthopedicBank'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      imageUrl: json['imageUrl'] as String?,
      availableQtd: json['availableQtd'] as int?,
      borrowedQtd: json['borrowedQtd'] as int?,
      maintenanceQtd: json['maintenanceQtd'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'orthopedicBank': orthopedicBank,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'availableQtd': availableQtd,
      'borrowedQtd': borrowedQtd,
      'maintenanceQtd': maintenanceQtd,
    };
  }

  Category copyWith({
    String? id,
    String? title,
    Map<String, dynamic>? orthopedicBank,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    int? availableQtd,
    int? borrowedQtd,
    int? maintenanceQtd,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      orthopedicBank: orthopedicBank ?? this.orthopedicBank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      availableQtd: availableQtd ?? this.availableQtd,
      borrowedQtd: borrowedQtd ?? this.borrowedQtd,
      maintenanceQtd: maintenanceQtd ?? this.maintenanceQtd,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, title: $title, bank: ${orthopedicBank['name']})';
  }

  String get orthopedicBankName => orthopedicBank['name'] as String? ?? '';
  String get orthopedicBankId => orthopedicBank['id'] as String? ?? '';
}
