import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

class UpdateBeneficiaryUseCase {
  final BeneficiaryRepository _repository;

  const UpdateBeneficiaryUseCase(this._repository);

  AsyncResult<Beneficiary> call({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  }) async {
    try {
      // Validar se há mudanças
      if (_isEmpty(updateBeneficiaryDTO)) {
        return Failure(Exception('Nenhuma alteração foi especificada'));
      }

      // Validações de negócio
      if (updateBeneficiaryDTO.name != null &&
          updateBeneficiaryDTO.name!.trim().length < 2) {
        return Failure(Exception('Nome deve ter pelo menos 2 caracteres'));
      }

      if (updateBeneficiaryDTO.cpf != null &&
          !_isValidCpf(updateBeneficiaryDTO.cpf!)) {
        return Failure(Exception('CPF inválido'));
      }

      if (updateBeneficiaryDTO.email != null &&
          !_isValidEmail(updateBeneficiaryDTO.email!)) {
        return Failure(Exception('Email inválido'));
      }

      if (updateBeneficiaryDTO.address != null &&
          updateBeneficiaryDTO.address!.trim().isEmpty) {
        return Failure(Exception('Endereço não pode estar vazio'));
      }

      return await _repository.updateBeneficiary(
        id: id,
        updateBeneficiaryDTO: updateBeneficiaryDTO,
      );
    } catch (e) {
      return Failure(Exception('Erro ao atualizar beneficiário: $e'));
    }
  }

  bool _isEmpty(UpdateBeneficiaryDTO dto) {
    return dto.name == null &&
        dto.cpf == null &&
        dto.email == null &&
        dto.phoneNumber == null &&
        dto.address == null;
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
