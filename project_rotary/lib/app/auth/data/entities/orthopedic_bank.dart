/// Entidade que representa um banco ortopédico no sistema.
/// Segue os princípios de Clean Architecture implementados em loans, applicants e categories.
class OrthopedicBank {
  final String id;
  final String name;
  final String city;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrthopedicBank({
    required this.id,
    required this.name,
    required this.city,
    required this.createdAt,
    this.updatedAt,
  });

  OrthopedicBank copyWith({
    String? id,
    String? name,
    String? city,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrthopedicBank(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrthopedicBank.fromMap(Map<String, dynamic> map) {
    return OrthopedicBank(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  @override
  String toString() {
    return 'OrthopedicBank(id: $id, name: $name, city: $city, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrthopedicBank &&
        other.id == id &&
        other.name == name &&
        other.city == city &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        city.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
