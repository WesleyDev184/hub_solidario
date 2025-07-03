import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

class GetBeneficiariesByApplicantUseCase {
  final BeneficiaryRepository _repository;

  const GetBeneficiariesByApplicantUseCase(this._repository);

  AsyncResult<List<Beneficiary>> call({required String applicantId}) async {
    try {
      if (applicantId.trim().isEmpty) {
        return Failure(Exception('ID do solicitante é obrigatório'));
      }

      return await _repository.getBeneficiariesByApplicantId(
        applicantId: applicantId,
      );
    } catch (e) {
      return Failure(Exception('Erro ao buscar beneficiários: $e'));
    }
  }
}
