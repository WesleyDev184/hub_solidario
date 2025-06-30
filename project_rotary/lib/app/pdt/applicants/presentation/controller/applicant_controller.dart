import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/create_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/delete_applicant_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/get_all_applicants_usecase.dart';
import 'package:project_rotary/app/pdt/applicants/domain/usecases/update_applicant_usecase.dart';
import 'package:result_dart/result_dart.dart';

class ApplicantController extends ChangeNotifier {
  final GetAllApplicantsUseCase _getAllApplicantsUseCase;
  final CreateApplicantUseCase _createApplicantUseCase;
  final UpdateApplicantUseCase _updateApplicantUseCase;
  final DeleteApplicantUseCase _deleteApplicantUseCase;

  ApplicantController({
    required GetAllApplicantsUseCase getAllApplicantsUseCase,
    required CreateApplicantUseCase createApplicantUseCase,
    required UpdateApplicantUseCase updateApplicantUseCase,
    required DeleteApplicantUseCase deleteApplicantUseCase,
  }) : _getAllApplicantsUseCase = getAllApplicantsUseCase,
       _createApplicantUseCase = createApplicantUseCase,
       _updateApplicantUseCase = updateApplicantUseCase,
       _deleteApplicantUseCase = deleteApplicantUseCase;

  bool _isLoading = false;
  String? _error;
  List<Applicant> _applicants = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Applicant> get applicants => List.unmodifiable(_applicants);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setApplicants(List<Applicant> applicants) {
    _applicants = applicants;
    notifyListeners();
  }

  AsyncResult<List<Applicant>> getAllApplicants() async {
    _setLoading(true);
    _setError(null);

    final result = await _getAllApplicantsUseCase();

    result.fold((applicants) {
      _setApplicants(applicants);
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<Applicant> createApplicant({
    required CreateApplicantDTO createApplicantDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _createApplicantUseCase(
      createApplicantDTO: createApplicantDTO,
    );

    result.fold((newApplicant) {
      _applicants.add(newApplicant);
      notifyListeners();
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<Applicant> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  }) async {
    _setLoading(true);
    _setError(null);

    final result = await _updateApplicantUseCase(
      id: id,
      updateApplicantDTO: updateApplicantDTO,
    );

    result.fold((updatedApplicant) {
      final index = _applicants.indexWhere((a) => a.id == id);
      if (index != -1) {
        _applicants[index] = updatedApplicant;
        notifyListeners();
      }
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  AsyncResult<String> deleteApplicant({required String id}) async {
    _setLoading(true);
    _setError(null);

    final result = await _deleteApplicantUseCase(id: id);

    result.fold((message) {
      _applicants.removeWhere((a) => a.id == id);
      notifyListeners();
      _setError(null);
    }, (error) => _setError(error.toString()));

    _setLoading(false);
    return result;
  }

  // Métodos de busca local
  List<Applicant> searchApplicants(String query) {
    if (query.isEmpty) return _applicants;

    final lowercaseQuery = query.toLowerCase();
    return _applicants.where((applicant) {
      return applicant.name.toLowerCase().contains(lowercaseQuery) ||
          applicant.cpf.contains(lowercaseQuery) ||
          applicant.email.toLowerCase().contains(lowercaseQuery) ||
          applicant.phoneNumber.contains(lowercaseQuery);
    }).toList();
  }

  Applicant? getApplicantById(String id) {
    try {
      return _applicants.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
