import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:result_dart/result_dart.dart';

abstract class BeneficiaryRepository {
  AsyncResult<String> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  });

  AsyncResult<String> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  });

  AsyncResult<String> deleteBeneficiary({required String id});
}
