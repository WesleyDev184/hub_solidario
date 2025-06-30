import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:result_dart/result_dart.dart';

abstract class ApplicantRepository {
  AsyncResult<String> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  });

  AsyncResult<String> deleteApplicant({required String id});
}
