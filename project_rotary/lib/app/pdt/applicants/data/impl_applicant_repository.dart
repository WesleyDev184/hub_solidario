import 'package:project_rotary/app/pdt/applicants/domain/applicant_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_applicant_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/applicant.dart';
import 'package:result_dart/result_dart.dart';

class ImplApplicantRepository implements ApplicantRepository {
  // Simulação de banco de dados em memória
  static final List<Applicant> _applicants = [
    Applicant(
      id: 'applicant_1',
      name: 'João Silva',
      cpf: '12345678901',
      email: 'joao@email.com',
      phoneNumber: '11987654321',
      address: 'Rua A, 123',
      isBeneficiary: true,
      beneficiaryIds: ['ben_1', 'ben_2'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Applicant(
      id: 'applicant_2',
      name: 'Maria Santos',
      cpf: '98765432109',
      email: 'maria@email.com',
      phoneNumber: '11876543210',
      address: 'Rua B, 456',
      isBeneficiary: false,
      beneficiaryIds: [],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  AsyncResult<List<Applicant>> getAllApplicants() async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(milliseconds: 800));

      // Simular falha ocasional (5% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 20 == 0) {
        return Failure(Exception('Erro do servidor ao buscar solicitantes'));
      }

      return Success(List.from(_applicants));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Applicant> getApplicantById({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(milliseconds: 500));

      final applicant = _applicants.where((a) => a.id == id).firstOrNull;

      if (applicant == null) {
        return Failure(Exception('Solicitante não encontrado'));
      }

      return Success(applicant);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Applicant> createApplicant({
    required CreateApplicantDTO createApplicantDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      // Verificar CPF duplicado
      if (_applicants.any((a) => a.cpf == createApplicantDTO.cpf)) {
        return Failure(Exception('CPF já cadastrado'));
      }

      // Verificar email duplicado
      if (_applicants.any((a) => a.email == createApplicantDTO.email)) {
        return Failure(Exception('Email já cadastrado'));
      }

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao criar solicitante'));
      }

      final newApplicant = Applicant(
        id: 'applicant_${_applicants.length + 1}',
        name: createApplicantDTO.name,
        cpf: createApplicantDTO.cpf,
        email: createApplicantDTO.email,
        phoneNumber: createApplicantDTO.phoneNumber,
        address: createApplicantDTO.address,
        isBeneficiary: createApplicantDTO.isBeneficiary,
        beneficiaryIds: [],
        createdAt: DateTime.now(),
      );

      _applicants.add(newApplicant);
      return Success(newApplicant);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Applicant> updateApplicant({
    required String id,
    required UpdateApplicantDTO updateApplicantDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      final index = _applicants.indexWhere((a) => a.id == id);
      if (index == -1) {
        return Failure(Exception('Solicitante não encontrado'));
      }

      final currentApplicant = _applicants[index];

      // Verificar CPF duplicado (se alterado)
      if (updateApplicantDTO.cpf != null &&
          updateApplicantDTO.cpf != currentApplicant.cpf &&
          _applicants.any(
            (a) => a.cpf == updateApplicantDTO.cpf && a.id != id,
          )) {
        return Failure(Exception('CPF já cadastrado por outro solicitante'));
      }

      // Verificar email duplicado (se alterado)
      if (updateApplicantDTO.email != null &&
          updateApplicantDTO.email != currentApplicant.email &&
          _applicants.any(
            (a) => a.email == updateApplicantDTO.email && a.id != id,
          )) {
        return Failure(Exception('Email já cadastrado por outro solicitante'));
      }

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao atualizar solicitante'));
      }

      final updatedApplicant = currentApplicant.copyWith(
        name: updateApplicantDTO.name ?? currentApplicant.name,
        cpf: updateApplicantDTO.cpf ?? currentApplicant.cpf,
        email: updateApplicantDTO.email ?? currentApplicant.email,
        phoneNumber:
            updateApplicantDTO.phoneNumber ?? currentApplicant.phoneNumber,
        address: updateApplicantDTO.address ?? currentApplicant.address,
        isBeneficiary:
            updateApplicantDTO.isBeneficiary ?? currentApplicant.isBeneficiary,
        updatedAt: DateTime.now(),
      );

      _applicants[index] = updatedApplicant;
      return Success(updatedApplicant);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<String> deleteApplicant({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      final index = _applicants.indexWhere((a) => a.id == id);
      if (index == -1) {
        return Failure(Exception('Solicitante não encontrado'));
      }

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao excluir solicitante'));
      }

      _applicants.removeAt(index);
      return Success('Solicitante excluído com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }
}
