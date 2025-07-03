import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

class BeneficiaryController extends ChangeNotifier {
  final BeneficiaryRepository _repository;

  BeneficiaryController(this._repository);

  bool _isLoading = false;
  String? _error;
  List<Beneficiary> _beneficiaries = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Beneficiary> get beneficiaries => List.unmodifiable(_beneficiaries);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setBeneficiaries(List<Beneficiary> beneficiaries) {
    _beneficiaries = beneficiaries;
    notifyListeners();
  }

  AsyncResult<List<Beneficiary>> getBeneficiariesByApplicantId({
    required String applicantId,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.getBeneficiariesByApplicantId(
      applicantId: applicantId,
    );

    result.fold((beneficiaries) {
      _setBeneficiaries(beneficiaries);
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<Beneficiary> getBeneficiaryById({required String id}) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.getBeneficiaryById(id: id);

    result.fold(
      (beneficiary) => _setError(null),
      (error) => _setError(error.toString()),
    );

    _setLoading(false);
    return result;
  }

  AsyncResult<Beneficiary> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.createBeneficiary(
      createBeneficiaryDTO: createBeneficiaryDTO,
    );

    result.fold((newBeneficiary) {
      _beneficiaries.add(newBeneficiary);
      notifyListeners();
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<Beneficiary> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.updateBeneficiary(
      id: id,
      updateBeneficiaryDTO: updateBeneficiaryDTO,
    );

    result.fold((updatedBeneficiary) {
      final index = _beneficiaries.indexWhere((b) => b.id == id);
      if (index != -1) {
        _beneficiaries[index] = updatedBeneficiary;
        notifyListeners();
      }
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<String> deleteBeneficiary({required String id}) async {
    _setLoading(true);
    _setError(null);

    final result = await _repository.deleteBeneficiary(id: id);

    result.fold((message) {
      _beneficiaries.removeWhere((b) => b.id == id);
      notifyListeners();
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  // Métodos de busca local
  List<Beneficiary> searchBeneficiaries(String query) {
    if (query.isEmpty) return _beneficiaries;

    final lowercaseQuery = query.toLowerCase();
    return _beneficiaries.where((beneficiary) {
      return beneficiary.name.toLowerCase().contains(lowercaseQuery) ||
          beneficiary.cpf.contains(lowercaseQuery) ||
          beneficiary.email.toLowerCase().contains(lowercaseQuery) ||
          beneficiary.phoneNumber.contains(lowercaseQuery);
    }).toList();
  }

  Beneficiary? getBeneficiaryByIdLocal(String id) {
    try {
      return _beneficiaries.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Beneficiary> getBeneficiariesByApplicantIdLocal(String applicantId) {
    return _beneficiaries.where((b) => b.applicantId == applicantId).toList();
  }
}
