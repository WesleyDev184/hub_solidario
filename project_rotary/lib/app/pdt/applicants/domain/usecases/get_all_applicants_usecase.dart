import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:result_dart/result_dart.dart';

class GetAllApplicantsUseCase {
  final ApplicantRepository _repository;

  const GetAllApplicantsUseCase(this._repository);

  AsyncResult<List<Applicant>> call() async {
    try {
      return await _repository.getAllApplicants();
    } catch (e) {
      return Failure(Exception('Erro ao buscar solicitantes: $e'));
    }
  }
}
