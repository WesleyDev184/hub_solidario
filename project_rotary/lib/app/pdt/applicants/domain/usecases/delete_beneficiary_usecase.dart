import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:result_dart/result_dart.dart';

class DeleteBeneficiaryUseCase {
  final BeneficiaryRepository _repository;

  const DeleteBeneficiaryUseCase(this._repository);

  AsyncResult<String> call({required String id}) async {
    try {
      if (id.trim().isEmpty) {
        return Failure(Exception('ID do beneficiário é obrigatório'));
      }

      return await _repository.deleteBeneficiary(id: id);
    } catch (e) {
      return Failure(Exception('Erro ao excluir beneficiário: $e'));
    }
  }
}
