class Category {
  final String id;
  final String title;
  final Map<String, dynamic> orthopedicBank;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Category({
    required this.id,
    required this.title,
    required this.orthopedicBank,
    required this.createdAt,
    this.updatedAt,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'orthopedicBank': orthopedicBank,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? title,
    Map<String, dynamic>? orthopedicBank,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      orthopedicBank: orthopedicBank ?? this.orthopedicBank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
