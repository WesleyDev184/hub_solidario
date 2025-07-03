import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:result_dart/result_dart.dart';

class DeleteApplicantUseCase {
  final ApplicantRepository _repository;

  const DeleteApplicantUseCase(this._repository);

  AsyncResult<String> call({required String id}) async {
    try {
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do solicitante é obrigatório'));
      }

      return await _repository.deleteApplicant(id: id);
    } catch (e) {
      return Failure(Exception('Erro ao excluir solicitante: $e'));
    }
  }
}
