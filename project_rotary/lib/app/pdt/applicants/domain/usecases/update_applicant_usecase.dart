import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:result_dart/result_dart.dart';

class UpdateApplicantUseCase {
  final ApplicantRepository _repository;

  const UpdateApplicantUseCase(this._repository);

  AsyncResult<Applicant> call({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  }) async {
    try {
      // Validar se há mudanças
      if (updateApplicantDTO.isEmpty) {
        return Failure(Exception('Nenhuma alteração foi especificada'));
      }

      // Validações de negócio
      if (updateApplicantDTO.name != null &&
          updateApplicantDTO.name!.trim().length < 2) {
        return Failure(Exception('Nome deve ter pelo menos 2 caracteres'));
      }

      if (updateApplicantDTO.cpf != null &&
          !_isValidCpf(updateApplicantDTO.cpf!)) {
        return Failure(Exception('CPF inválido'));
      }

      if (updateApplicantDTO.email != null &&
          !_isValidEmail(updateApplicantDTO.email!)) {
        return Failure(Exception('Email inválido'));
      }

      return await _repository.updateApplicant(
        id: id,
        updateApplicantDTO: updateApplicantDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao atualizar solicitante: $e'));
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
