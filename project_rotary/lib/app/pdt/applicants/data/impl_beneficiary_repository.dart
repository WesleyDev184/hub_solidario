import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:result_dart/result_dart.dart';

class ImplBeneficiaryRepository implements BeneficiaryRepository {
  @override
  AsyncResult<String> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 2));

      // Simular falha ocasional (15% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
        return Failure(Exception('Erro do servidor ao criar beneficiário'));
      }

      // Simular sucesso
      return Success('Beneficiário criado com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<String> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao atualizar beneficiário'));
      }

      // Simular sucesso
      return Success('Beneficiário atualizado com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<String> deleteBeneficiary({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao excluir beneficiário'));
      }

      // Simular sucesso
      return Success('Beneficiário excluído com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }
}
