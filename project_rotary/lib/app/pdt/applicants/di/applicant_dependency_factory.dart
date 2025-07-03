import 'package:project_rotary/app/pdt/applicants/data/impl_applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/data/impl_beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/create_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/create_beneficiary_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/delete_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/delete_beneficiary_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/get_all_applicants_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/get_beneficiaries_by_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/update_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/update_beneficiary_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/controller/applicant_controller.dart';
import 'package:project_rotary/app/pdt/applicants/presentation/controller/beneficiary_controller.dart';

class ApplicantDependencyFactory {
  static ApplicantRepository get applicantRepository =>
      ImplApplicantRepository();
  static BeneficiaryRepository get beneficiaryRepository =>
      ImplBeneficiaryRepository();

  // Applicant Use Cases
  static GetAllApplicantsUseCase get getAllApplicantsUseCase =>
      GetAllApplicantsUseCase(applicantRepository);

  static CreateApplicantUseCase get createApplicantUseCase =>
      CreateApplicantUseCase(applicantRepository);

  static UpdateApplicantUseCase get updateApplicantUseCase =>
      UpdateApplicantUseCase(applicantRepository);

  static DeleteApplicantUseCase get deleteApplicantUseCase =>
      DeleteApplicantUseCase(applicantRepository);

  // Beneficiary Use Cases
  static GetBeneficiariesByApplicantUseCase
  get getBeneficiariesByApplicantUseCase =>
      GetBeneficiariesByApplicantUseCase(beneficiaryRepository);

  static CreateBeneficiaryUseCase get createBeneficiaryUseCase =>
      CreateBeneficiaryUseCase(beneficiaryRepository);

  static UpdateBeneficiaryUseCase get updateBeneficiaryUseCase =>
      UpdateBeneficiaryUseCase(beneficiaryRepository);

  static DeleteBeneficiaryUseCase get deleteBeneficiaryUseCase =>
      DeleteBeneficiaryUseCase(beneficiaryRepository);

  // Controllers
  static ApplicantController get applicantController => ApplicantController(
    getAllApplicantsUseCase: getAllApplicantsUseCase,
    createApplicantUseCase: createApplicantUseCase,
    updateApplicantUseCase: updateApplicantUseCase,
    deleteApplicantUseCase: deleteApplicantUseCase,
  );

  static BeneficiaryController get beneficiaryController =>
      BeneficiaryController(beneficiaryRepository);
}
