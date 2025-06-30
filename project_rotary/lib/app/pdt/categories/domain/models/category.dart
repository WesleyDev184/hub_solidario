class Category {
  final String id;
  final String title;
  final Map<String, dynamic> orthopedicBank;
  final String createdAt;

  Category({
    required this.id,
    required this.title,
    required this.orthopedicBank,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      title: json['title'],
      orthopedicBank: json['orthopedicBank'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'orthopedicBank': orthopedicBank,
      'createdAt': createdAt,
    };
  }
}
