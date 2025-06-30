import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:result_dart/result_dart.dart';

class BeneficiaryController extends ChangeNotifier {
  final BeneficiaryRepository _repository;

  BeneficiaryController(this._repository);

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

  AsyncResult<String> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.createBeneficiary(
      createBeneficiaryDTO: createBeneficiaryDTO,
    );

    result.fold(
      (success) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }

  AsyncResult<String> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.updateBeneficiary(
      id: id,
      updateBeneficiaryDTO: updateBeneficiaryDTO,
    );

    result.fold(
      (success) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }

  AsyncResult<String> deleteBeneficiary({required String id}) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.deleteBeneficiary(id: id);

    result.fold(
      (success) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }
}
