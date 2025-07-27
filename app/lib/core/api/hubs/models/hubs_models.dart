import 'package:app/core/api/auth/models/auth_models.dart';

/// Modelo para banco ortopédico
class Hub {
  final String id;
  final String name;
  final String city;
  final List<dynamic>? stocks;
  final DateTime createdAt;

  const Hub({
    required this.id,
    required this.name,
    required this.city,
    this.stocks,
    required this.createdAt,
  });

  factory Hub.fromJson(Map<String, dynamic> json) => Hub(
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

  Hub copyWith({
    String? id,
    String? name,
    String? city,
    List<dynamic>? stocks,
    DateTime? createdAt,
  }) {
    return Hub(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      stocks: stocks ?? this.stocks,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Modelo para criação de banco ortopédico
class CreateHubRequest {
  final String name;
  final String city;

  const CreateHubRequest({required this.name, required this.city});

  factory CreateHubRequest.fromJson(Map<String, dynamic> json) =>
      CreateHubRequest(
        name: json['name'] as String,
        city: json['city'] as String,
      );

  Map<String, dynamic> toJson() => {'name': name, 'city': city};
}

/// Modelo para atualização de banco ortopédico
class UpdateHubRequest {
  final String? name;
  final String? city;

  const UpdateHubRequest({this.name, this.city});

  factory UpdateHubRequest.fromJson(Map<String, dynamic> json) =>
      UpdateHubRequest(
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
typedef HubResponse = ControllerResponse<Hub>;

/// Tipo específico para resposta de lista de bancos ortopédicos
typedef HubListResponse = ControllerResponse<List<Hub>>;
