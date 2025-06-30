import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

abstract class BeneficiaryRepository {
  AsyncResult<List<Beneficiary>> getBeneficiariesByApplicantId({
    required String applicantId,
  });

  AsyncResult<Beneficiary> getBeneficiaryById({required String id});

  AsyncResult<Beneficiary> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  });

  AsyncResult<Beneficiary> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  });

  AsyncResult<String> deleteBeneficiary({required String id});
}
