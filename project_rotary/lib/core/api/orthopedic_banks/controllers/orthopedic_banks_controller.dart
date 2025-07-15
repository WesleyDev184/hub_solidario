import 'package:result_dart/result_dart.dart';

import '../models/orthopedic_banks_models.dart';
import '../repositories/orthopedic_banks_repository.dart';
import '../services/orthopedic_banks_cache_service.dart';

/// Controller para gerenciar operações de bancos ortopédicos
class OrthopedicBanksController {
  final OrthopedicBanksRepository _repository;
  final OrthopedicBanksCacheService _cacheService;

  bool _isLoading = false;
  String? _error;

  OrthopedicBanksController(this._repository, this._cacheService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Busca todos os bancos ortopédicos
  AsyncResult<List<OrthopedicBank>> loadOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading = true;
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedState = await _cacheService.loadOrthopedicBanksState();
        if (cachedState.isNotEmpty) {
          _isLoading = false;
          return Success(cachedState);
        }
      }

      final result = await _repository.getOrthopedicBanks(
        forceRefresh: forceRefresh,
      );

      return result.fold(
        (banks) async {
          await _cacheService.saveOrthopedicBanksState(banks);
          _isLoading = false;
          return Success(banks);
        },
        (error) {
          _isLoading = false;
          return Failure(error);
        },
      );
    } catch (e) {
      _isLoading = false;
      return Failure(Exception('Erro ao carregar bancos ortopédicos: $e'));
    }
  }

  /// Cria um novo banco ortopédico
  AsyncResult<String> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    try {
      final result = await _repository.createOrthopedicBank(request);
      return result.fold((bank) async {
        await _cacheService.saveOrthopedicBankState(bank);
        return Success(bank.id);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao criar banco ortopédico: $e'));
    }
  }

  /// Atualiza um banco ortopédico
  AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    try {
      final result = await _repository.updateOrthopedicBank(bankId, request);
      return result.fold((bank) async {
        await _cacheService.updateOrthopedicBankState(bank);
        return Success(bank);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao atualizar banco ortopédico: $e'));
    }
  }

  /// Deleta um banco ortopédico
  AsyncResult<bool> deleteOrthopedicBank(String bankId) async {
    try {
      final result = await _repository.deleteOrthopedicBank(bankId);
      return result.fold((_) async {
        await _cacheService.removeOrthopedicBankState(bankId);
        return Success(true);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro ao deletar banco ortopédico: $e'));
    }
  }
}
