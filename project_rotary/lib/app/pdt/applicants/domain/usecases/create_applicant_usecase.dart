import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:result_dart/result_dart.dart';

class CreateApplicantUseCase {
  final ApplicantRepository _repository;

  const CreateApplicantUseCase(this._repository);

  AsyncResult<Applicant> call({
    required CreateApplicantDTO createApplicantDTO,
  }) async {
    try {
      // Validações de negócio podem ser adicionadas aqui
      if (createApplicantDTO.name.trim().length < 2) {
        return Failure(Exception('Nome deve ter pelo menos 2 caracteres'));
      }

      if (!_isValidCpf(createApplicantDTO.cpf)) {
        return Failure(Exception('CPF inválido'));
      }

      if (!_isValidEmail(createApplicantDTO.email)) {
        return Failure(Exception('Email inválido'));
      }

      return await _repository.createApplicant(
        createApplicantDTO: createApplicantDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao criar solicitante: $e'));
    }
  }

  bool _isValidCpf(String cpf) {
    final cleanCpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCpf.length == 11;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
