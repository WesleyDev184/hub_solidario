/// Modelo para representar um requerente/candidato
class Applicant {
  final String id;
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final bool isBeneficiary;
  final int beneficiaryQtd;
  final DateTime createdAt;
  final List<Dependent>? dependents;

  const Applicant({
    required this.id,
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    required this.isBeneficiary,
    required this.beneficiaryQtd,
    required this.createdAt,
    this.dependents,
  });

  /// Cria instância a partir de JSON
  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id'] as String,
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      isBeneficiary: json['isBeneficiary'] as bool? ?? false,
      beneficiaryQtd: json['beneficiaryQtd'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dependents:
          json['dependents'] != null
              ? (json['dependents'] as List)
                  .map((dep) => Dependent.fromJson(dep as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'isBeneficiary': isBeneficiary,
      'beneficiaryQtd': beneficiaryQtd,
      'createdAt': createdAt.toIso8601String(),
      'dependents': dependents?.map((dep) => dep.toJson()).toList(),
    };
  }

  /// Cria cópia com alterações
  Applicant copyWith({
    String? id,
    String? name,
    String? cpf,
    String? email,
    String? phoneNumber,
    String? address,
    bool? isBeneficiary,
    int? beneficiaryQtd,
    DateTime? createdAt,
    List<Dependent>? dependents,
  }) {
    return Applicant(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isBeneficiary: isBeneficiary ?? this.isBeneficiary,
      beneficiaryQtd: beneficiaryQtd ?? this.beneficiaryQtd,
      createdAt: createdAt ?? this.createdAt,
      dependents: dependents ?? this.dependents,
    );
  }

  /// Verifica se tem dados válidos para contato
  bool get hasValidContact =>
      (email != null && email!.isNotEmpty) ||
      (phoneNumber != null && phoneNumber!.isNotEmpty);

  /// Número total de pessoas (candidato + dependentes)
  int get totalPeople => 1 + (dependents?.length ?? 0);

  @override
  String toString() =>
      'Applicant(id: $id, name: $name, isBeneficiary: $isBeneficiary)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Applicant && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Modelo para representar um dependente
class Dependent {
  final String id;
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String applicantId;
  final DateTime createdAt;

  const Dependent({
    required this.id,
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    required this.applicantId,
    required this.createdAt,
  });

  /// Cria instância a partir de JSON
  factory Dependent.fromJson(Map<String, dynamic> json) {
    return Dependent(
      id: json['id'] as String,
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      applicantId: json['applicantId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'applicantId': applicantId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Cria cópia com alterações
  Dependent copyWith({
    String? id,
    String? name,
    String? cpf,
    String? email,
    String? phoneNumber,
    String? address,
    String? applicantId,
    DateTime? createdAt,
  }) {
    return Dependent(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      applicantId: applicantId ?? this.applicantId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Verifica se tem dados válidos para contato
  bool get hasValidContact =>
      (email != null && email!.isNotEmpty) ||
      (phoneNumber != null && phoneNumber!.isNotEmpty);

  @override
  String toString() =>
      'Dependent(id: $id, name: $name, applicantId: $applicantId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dependent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Request para criar um novo candidato
class CreateApplicantRequest {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final bool isBeneficiary;

  const CreateApplicantRequest({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    required this.isBeneficiary,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'isBeneficiary': isBeneficiary,
    };
  }

  /// Cria instância a partir de JSON
  factory CreateApplicantRequest.fromJson(Map<String, dynamic> json) {
    return CreateApplicantRequest(
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      isBeneficiary: json['isBeneficiary'] as bool? ?? false,
    );
  }
}

/// Request para atualizar um candidato existente
class UpdateApplicantRequest {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final bool? isBeneficiary;

  const UpdateApplicantRequest({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    this.isBeneficiary,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null) json['name'] = name;
    if (cpf != null) json['cpf'] = cpf;
    if (email != null) json['email'] = email;
    if (phoneNumber != null) json['phoneNumber'] = phoneNumber;
    if (address != null) json['address'] = address;
    if (isBeneficiary != null) json['isBeneficiary'] = isBeneficiary;

    return json;
  }

  /// Cria instância a partir de JSON
  factory UpdateApplicantRequest.fromJson(Map<String, dynamic> json) {
    return UpdateApplicantRequest(
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      isBeneficiary: json['isBeneficiary'] as bool?,
    );
  }

  /// Verifica se há campos para atualizar
  bool get hasUpdates =>
      name != null ||
      cpf != null ||
      email != null ||
      phoneNumber != null ||
      address != null ||
      isBeneficiary != null;
}

/// Request para criar um novo dependente
class CreateDependentRequest {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String applicantId;

  const CreateDependentRequest({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
    required this.applicantId,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'applicantId': applicantId,
    };
  }

  /// Cria instância a partir de JSON
  factory CreateDependentRequest.fromJson(Map<String, dynamic> json) {
    return CreateDependentRequest(
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      applicantId: json['applicantId'] as String,
    );
  }
}

/// Request para atualizar um dependente existente
class UpdateDependentRequest {
  final String? name;
  final String? cpf;
  final String? email;
  final String? phoneNumber;
  final String? address;

  const UpdateDependentRequest({
    this.name,
    this.cpf,
    this.email,
    this.phoneNumber,
    this.address,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null) json['name'] = name;
    if (cpf != null) json['cpf'] = cpf;
    if (email != null) json['email'] = email;
    if (phoneNumber != null) json['phoneNumber'] = phoneNumber;
    if (address != null) json['address'] = address;

    return json;
  }

  /// Cria instância a partir de JSON
  factory UpdateDependentRequest.fromJson(Map<String, dynamic> json) {
    return UpdateDependentRequest(
      name: json['name'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Verifica se há campos para atualizar
  bool get hasUpdates =>
      name != null ||
      cpf != null ||
      email != null ||
      phoneNumber != null ||
      address != null;
}

/// Response para criação de candidato
class CreateApplicantResponse {
  final bool success;
  final String? applicantId;
  final String? message;

  const CreateApplicantResponse({
    required this.success,
    this.applicantId,
    this.message,
  });

  /// Cria instância a partir de JSON
  factory CreateApplicantResponse.fromJson(Map<String, dynamic> json) {
    return CreateApplicantResponse(
      success: json['success'] as bool? ?? false,
      applicantId: json['data'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Response para atualização de candidato
class UpdateApplicantResponse {
  final bool success;
  final Applicant? applicant;
  final String? message;

  const UpdateApplicantResponse({
    required this.success,
    this.applicant,
    this.message,
  });

  /// Cria instância a partir de JSON
  factory UpdateApplicantResponse.fromJson(Map<String, dynamic> json) {
    return UpdateApplicantResponse(
      success: json['success'] as bool? ?? false,
      applicant:
          json['data'] != null
              ? Applicant.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }
}

/// Response para deleção de candidato
class DeleteApplicantResponse {
  final bool success;
  final String? message;

  const DeleteApplicantResponse({required this.success, this.message});

  /// Cria instância a partir de JSON
  factory DeleteApplicantResponse.fromJson(Map<String, dynamic> json) {
    return DeleteApplicantResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Response para criação de dependente
class CreateDependentResponse {
  final bool success;
  final String? dependentId;
  final String? message;

  const CreateDependentResponse({
    required this.success,
    this.dependentId,
    this.message,
  });

  /// Cria instância a partir de JSON
  factory CreateDependentResponse.fromJson(Map<String, dynamic> json) {
    return CreateDependentResponse(
      success: json['success'] as bool? ?? false,
      dependentId: json['data'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Response para atualização de dependente
class UpdateDependentResponse {
  final bool success;
  final Dependent? dependent;
  final String? message;

  const UpdateDependentResponse({
    required this.success,
    this.dependent,
    this.message,
  });

  /// Cria instância a partir de JSON
  factory UpdateDependentResponse.fromJson(Map<String, dynamic> json) {
    return UpdateDependentResponse(
      success: json['success'] as bool? ?? false,
      dependent:
          json['data'] != null
              ? Dependent.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }
}

/// Response para deleção de dependente
class DeleteDependentResponse {
  final bool success;
  final String? message;

  const DeleteDependentResponse({required this.success, this.message});

  /// Cria instância a partir de JSON
  factory DeleteDependentResponse.fromJson(Map<String, dynamic> json) {
    return DeleteDependentResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Filtros para busca de candidatos
class ApplicantFilters {
  final String? name;
  final String? cpf;
  final String? email;
  final bool? isBeneficiary;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const ApplicantFilters({
    this.name,
    this.cpf,
    this.email,
    this.isBeneficiary,
    this.createdAfter,
    this.createdBefore,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (name != null) params['name'] = name!;
    if (cpf != null) params['cpf'] = cpf!;
    if (email != null) params['email'] = email!;
    if (isBeneficiary != null) {
      params['isBeneficiary'] = isBeneficiary.toString();
    }
    if (createdAfter != null) {
      params['createdAfter'] = createdAfter!.toIso8601String();
    }
    if (createdBefore != null) {
      params['createdBefore'] = createdBefore!.toIso8601String();
    }

    return params;
  }

  bool get hasFilters =>
      name != null ||
      cpf != null ||
      email != null ||
      isBeneficiary != null ||
      createdAfter != null ||
      createdBefore != null;
}

/// Filtros para busca de dependentes
class DependentFilters {
  final String? name;
  final String? cpf;
  final String? email;
  final String? applicantId;
  final DateTime? createdAfter;
  final DateTime? createdBefore;

  const DependentFilters({
    this.name,
    this.cpf,
    this.email,
    this.applicantId,
    this.createdAfter,
    this.createdBefore,
  });

  Map<String, String> toQueryParams() {
    final Map<String, String> params = {};

    if (name != null) params['name'] = name!;
    if (cpf != null) params['cpf'] = cpf!;
    if (email != null) params['email'] = email!;
    if (applicantId != null) params['applicantId'] = applicantId!;
    if (createdAfter != null) {
      params['createdAfter'] = createdAfter!.toIso8601String();
    }
    if (createdBefore != null) {
      params['createdBefore'] = createdBefore!.toIso8601String();
    }

    return params;
  }

  bool get hasFilters =>
      name != null ||
      cpf != null ||
      email != null ||
      applicantId != null ||
      createdAfter != null ||
      createdBefore != null;
}
