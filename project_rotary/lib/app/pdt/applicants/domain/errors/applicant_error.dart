/// Enumeração dos tipos de erro específicos do domínio de Applicants
enum ApplicantErrorType {
  notFound,
  duplicateCpf,
  duplicateEmail,
  invalidCpf,
  invalidEmail,
  invalidName,
  invalidPhoneNumber,
  networkError,
  serverError,
  validationError,
  unknown,
}

/// Classe para representar erros do domínio de Applicants de forma estruturada
class ApplicantError implements Exception {
  final ApplicantErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;

  const ApplicantError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
  });

  factory ApplicantError.notFound([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.notFound,
      message: 'Solicitante não encontrado',
      details: details,
    );
  }

  factory ApplicantError.duplicateCpf([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.duplicateCpf,
      message: 'CPF já cadastrado',
      details: details,
    );
  }

  factory ApplicantError.duplicateEmail([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.duplicateEmail,
      message: 'Email já cadastrado',
      details: details,
    );
  }

  factory ApplicantError.invalidCpf([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.invalidCpf,
      message: 'CPF inválido',
      details: details,
    );
  }

  factory ApplicantError.invalidEmail([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.invalidEmail,
      message: 'Email inválido',
      details: details,
    );
  }

  factory ApplicantError.invalidName([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.invalidName,
      message: 'Nome inválido',
      details: details,
    );
  }

  factory ApplicantError.networkError([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.networkError,
      message: 'Erro de conexão',
      details: details,
    );
  }

  factory ApplicantError.serverError([String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.serverError,
      message: 'Erro do servidor',
      details: details,
    );
  }

  factory ApplicantError.validationError(String message, [String? details]) {
    return ApplicantError(
      type: ApplicantErrorType.validationError,
      message: message,
      details: details,
    );
  }

  factory ApplicantError.unknown([String? details, dynamic originalError]) {
    return ApplicantError(
      type: ApplicantErrorType.unknown,
      message: 'Erro desconhecido',
      details: details,
      originalError: originalError,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer(message);
    if (details != null) {
      buffer.write(': $details');
    }
    return buffer.toString();
  }

  /// Verifica se o erro é recuperável (pode tentar novamente)
  bool get isRecoverable {
    return type == ApplicantErrorType.networkError ||
        type == ApplicantErrorType.serverError;
  }

  /// Verifica se o erro é de validação (input do usuário)
  bool get isValidationError {
    return type == ApplicantErrorType.validationError ||
        type == ApplicantErrorType.invalidCpf ||
        type == ApplicantErrorType.invalidEmail ||
        type == ApplicantErrorType.invalidName ||
        type == ApplicantErrorType.invalidPhoneNumber;
  }
}
