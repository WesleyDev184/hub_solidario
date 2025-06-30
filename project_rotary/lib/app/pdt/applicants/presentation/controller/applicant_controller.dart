import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:result_dart/result_dart.dart';

class ApplicantController extends ChangeNotifier {
  final ApplicantRepository _repository;

  ApplicantController(this._repository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  AsyncResult<String> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.updateApplicant(
      id: id,
      updateApplicantDTO: updateApplicantDTO,
    );

    result.fold(
      (success) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }

  AsyncResult<String> deleteApplicant({required String id}) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.deleteApplicant(id: id);

    result.fold(
      (success) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }
}
