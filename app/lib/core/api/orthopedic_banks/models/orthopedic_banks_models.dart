import 'package:app/core/api/auth/models/auth_models.dart';

/// Modelo para banco ortopédico
class OrthopedicBank {
  final String id;
  final String name;
  final String city;
  final List<dynamic>? stocks;
  final DateTime createdAt;

  const OrthopedicBank({
    required this.id,
    required this.name,
    required this.city,
    this.stocks,
    required this.createdAt,
  });

  factory OrthopedicBank.fromJson(Map<String, dynamic> json) => OrthopedicBank(
    id: json['id'] as String,
    name: json['name'] as String,
    city: json['city'] as String,
    stocks: json['stocks'] as List<dynamic>?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'stocks': stocks,
    'createdAt': createdAt.toIso8601String(),
  };

  OrthopedicBank copyWith({
    String? id,
    String? name,
    String? city,
    List<dynamic>? stocks,
    DateTime? createdAt,
  }) {
    return OrthopedicBank(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      stocks: stocks ?? this.stocks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Modelo para criação de banco ortopédico
class CreateOrthopedicBankRequest {
  final String name;
  final String city;

  const CreateOrthopedicBankRequest({required this.name, required this.city});

  factory CreateOrthopedicBankRequest.fromJson(Map<String, dynamic> json) =>
      CreateOrthopedicBankRequest(
        name: json['name'] as String,
        city: json['city'] as String,
      );

  Map<String, dynamic> toJson() => {'name': name, 'city': city};
}

/// Modelo para atualização de banco ortopédico
class UpdateOrthopedicBankRequest {
  final String? name;
  final String? city;

  const UpdateOrthopedicBankRequest({this.name, this.city});

  factory UpdateOrthopedicBankRequest.fromJson(Map<String, dynamic> json) =>
      UpdateOrthopedicBankRequest(
        name: json['name'] as String?,
        city: json['city'] as String?,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (city != null) map['city'] = city;
    return map;
  }
}

/// Tipo específico para resposta de banco ortopédico único
typedef OrthopedicBankResponse = ControllerResponse<OrthopedicBank>;

/// Tipo específico para resposta de lista de bancos ortopédicos
typedef OrthopedicBankListResponse = ControllerResponse<List<OrthopedicBank>>;
