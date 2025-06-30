import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

class CreateBeneficiaryUseCase {
  final BeneficiaryRepository _repository;

  const CreateBeneficiaryUseCase(this._repository);

  AsyncResult<Beneficiary> call({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  }) async {
    try {
      // Validações de negócio
      if (createBeneficiaryDTO.name.trim().length < 2) {
        return Failure(Exception('Nome deve ter pelo menos 2 caracteres'));
      }

      if (!_isValidCpf(createBeneficiaryDTO.cpf)) {
        return Failure(Exception('CPF inválido'));
      }

      if (!_isValidEmail(createBeneficiaryDTO.email)) {
        return Failure(Exception('Email inválido'));
      }

      if (createBeneficiaryDTO.address.trim().isEmpty) {
        return Failure(Exception('Endereço é obrigatório'));
      }

      if (createBeneficiaryDTO.applicantId.trim().isEmpty) {
        return Failure(Exception('ID do solicitante é obrigatório'));
      }

      return await _repository.createBeneficiary(
        createBeneficiaryDTO: createBeneficiaryDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao criar beneficiário: $e'));
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
