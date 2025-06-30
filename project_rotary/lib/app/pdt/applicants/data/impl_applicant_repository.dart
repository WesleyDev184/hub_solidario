import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:result_dart/result_dart.dart';

class ImplApplicantRepository implements ApplicantRepository {
  @override
  AsyncResult<String> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao atualizar solicitante'));
      }

      // Simular sucesso
      return Success('Solicitante atualizado com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<String> deleteApplicant({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao excluir solicitante'));
      }

      // Simular sucesso
      return Success('Solicitante excluído com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }
}
