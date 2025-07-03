import 'package:project_rotary/app/pdt/applicants/domain/beneficiary_repository.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/create_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/dto/update_beneficiary_dto.dart';
import 'package:project_rotary/app/pdt/applicants/domain/entities/beneficiary.dart';
import 'package:result_dart/result_dart.dart';

class ImplBeneficiaryRepository implements BeneficiaryRepository {
  // Simulação de banco de dados em memória
  static final List<Beneficiary> _beneficiaries = [
    Beneficiary(
      id: 'ben_1',
      name: 'Maria Silva',
      cpf: '11122233344',
      email: 'maria.silva@email.com',
      phoneNumber: '11998887777',
      address: 'Rua das Flores, 123, São Paulo, SP',
      applicantId: 'applicant_1',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Beneficiary(
      id: 'ben_2',
      name: 'João Santos',
      cpf: '55566677788',
      email: 'joao.santos@email.com',
      phoneNumber: '11987776666',
      address: 'Av. Paulista, 456, São Paulo, SP',
      applicantId: 'applicant_1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  AsyncResult<List<Beneficiary>> getBeneficiariesByApplicantId({
    required String applicantId,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(milliseconds: 600));

      // Simular falha ocasional (5% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 20 == 0) {
        return Failure(Exception('Erro do servidor ao buscar beneficiários'));
      }

      final beneficiaries =
          _beneficiaries.where((b) => b.applicantId == applicantId).toList();

      return Success(beneficiaries);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Beneficiary> getBeneficiaryById({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(milliseconds: 400));

      final beneficiary = _beneficiaries.where((b) => b.id == id).firstOrNull;

      if (beneficiary == null) {
        return Failure(Exception('Beneficiário não encontrado'));
      }

      return Success(beneficiary);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Beneficiary> createBeneficiary({
    required CreateBeneficiaryDTO createBeneficiaryDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 2));

      // Verificar CPF duplicado
      if (_beneficiaries.any((b) => b.cpf == createBeneficiaryDTO.cpf)) {
        return Failure(Exception('CPF já cadastrado'));
      }

      // Verificar email duplicado
      if (_beneficiaries.any((b) => b.email == createBeneficiaryDTO.email)) {
        return Failure(Exception('Email já cadastrado'));
      }

      // Simular falha ocasional (15% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 7 == 0) {
        return Failure(Exception('Erro do servidor ao criar beneficiário'));
      }

      final newBeneficiary = Beneficiary(
        id: 'ben_${_beneficiaries.length + 1}',
        name: createBeneficiaryDTO.name,
        cpf: createBeneficiaryDTO.cpf,
        email: createBeneficiaryDTO.email,
        phoneNumber: createBeneficiaryDTO.phoneNumber,
        address: createBeneficiaryDTO.address,
        applicantId: createBeneficiaryDTO.applicantId,
        createdAt: DateTime.now(),
      );

      _beneficiaries.add(newBeneficiary);
      return Success(newBeneficiary);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<Beneficiary> updateBeneficiary({
    required String id,
    required UpdateBeneficiaryDTO updateBeneficiaryDTO,
  }) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      final index = _beneficiaries.indexWhere((b) => b.id == id);
      if (index == -1) {
        return Failure(Exception('Beneficiário não encontrado'));
      }

      final currentBeneficiary = _beneficiaries[index];

      // Verificar CPF duplicado (se alterado)
      if (updateBeneficiaryDTO.cpf != null &&
          updateBeneficiaryDTO.cpf != currentBeneficiary.cpf &&
          _beneficiaries.any(
            (b) => b.cpf == updateBeneficiaryDTO.cpf && b.id != id,
          )) {
        return Failure(Exception('CPF já cadastrado por outro beneficiário'));
      }

      // Verificar email duplicado (se alterado)
      if (updateBeneficiaryDTO.email != null &&
          updateBeneficiaryDTO.email != currentBeneficiary.email &&
          _beneficiaries.any(
            (b) => b.email == updateBeneficiaryDTO.email && b.id != id,
          )) {
        return Failure(Exception('Email já cadastrado por outro beneficiário'));
      }

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao atualizar beneficiário'));
      }

      final updatedBeneficiary = currentBeneficiary.copyWith(
        name: updateBeneficiaryDTO.name ?? currentBeneficiary.name,
        cpf: updateBeneficiaryDTO.cpf ?? currentBeneficiary.cpf,
        email: updateBeneficiaryDTO.email ?? currentBeneficiary.email,
        phoneNumber:
            updateBeneficiaryDTO.phoneNumber ?? currentBeneficiary.phoneNumber,
        address: updateBeneficiaryDTO.address ?? currentBeneficiary.address,
        updatedAt: DateTime.now(),
      );

      _beneficiaries[index] = updatedBeneficiary;
      return Success(updatedBeneficiary);
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  @override
  AsyncResult<String> deleteBeneficiary({required String id}) async {
    try {
      // Simular delay da API
      await Future.delayed(const Duration(seconds: 1));

      final index = _beneficiaries.indexWhere((b) => b.id == id);
      if (index == -1) {
        return Failure(Exception('Beneficiário não encontrado'));
      }

      // Simular falha ocasional (10% das vezes)
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Failure(Exception('Erro do servidor ao excluir beneficiário'));
      }

      _beneficiaries.removeAt(index);
      return Success('Beneficiário excluído com sucesso');
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }
}
