import 'package:project_rotary/app/pdt/applicants/domain/dto/create_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:result_dart/result_dart.dart';

abstract class ApplicantRepository {
  AsyncResult<List<Applicant>> getAllApplicants();

  AsyncResult<Applicant> getApplicantById({required String id});

  AsyncResult<Applicant> createApplicant({
    required CreateApplicantDTO createApplicantDTO,
  });

  AsyncResult<Applicant> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  });

  AsyncResult<String> deleteApplicant({required String id});
}
