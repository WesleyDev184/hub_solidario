import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:result_dart/result_dart.dart';

import '../models/orthopedic_banks_models.dart';
import '../repositories/orthopedic_banks_repository.dart';

/// Controlador de bancos ortopédicos com cache e manipulação otimista
class OrthopedicBanksController extends ChangeNotifier {
  final OrthopedicBanksRepository _repository;

  OrthopedicBanksState _state = const OrthopedicBanksState();
  OrthopedicBanksState get state => _state;

  bool get isLoading => _state.isLoading;
  List<OrthopedicBank> get banks => _state.banks;
  bool get isEmpty => _state.isEmpty;
  bool get isNotEmpty => _state.isNotEmpty;
  int get count => _state.count;

  bool _isInitialized = false;
  StreamController<OrthopedicBanksState>? _stateController;

  OrthopedicBanksController({required OrthopedicBanksRepository repository})
    : _repository = repository;

  /// Stream do estado dos bancos ortopédicos
  Stream<OrthopedicBanksState> get stateStream {
    _stateController ??= StreamController<OrthopedicBanksState>.broadcast();
    return _stateController!.stream;
  }

  /// Inicializa o controlador carregando estado do cache
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);

      debugPrint(
        'OrthopedicBanksController.initialize: Starting initialization',
      );

      // Carrega estado do cache
      debugPrint('OrthopedicBanksController.initialize: Loading cached state');
      final cachedState = await _repository.loadCachedState();
      _updateState(cachedState);

      debugPrint(
        'OrthopedicBanksController.initialize: Cached state loaded, banks: ${cachedState.count}',
      );

      _isInitialized = true;
      debugPrint(
        'OrthopedicBanksController.initialize: Initialization completed',
      );
    } catch (e) {
      debugPrint(
        'OrthopedicBanksController.initialize: Error during initialization: $e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega todos os bancos ortopédicos
  AsyncResult<List<OrthopedicBank>> loadOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    try {
      _setLoading(true);

      debugPrint('Loading orthopedic banks, forceRefresh: $forceRefresh');

      final result = await _repository.getOrthopedicBanks(
        forceRefresh: forceRefresh,
      );

      return result.fold(
        (success) {
          _updateState(
            _state.copyWith(banks: success, lastUpdated: DateTime.now()),
          );
          debugPrint('Orthopedic banks loaded successfully: ${success.length}');
          return Success(success);
        },
        (failure) {
          debugPrint('Error loading orthopedic banks: $failure');
          return Failure(failure);
        },
      );
    } catch (e) {
      debugPrint('Error in loadOrthopedicBanks: $e');
      return Failure(
        Exception('Erro ao carregar bancos ortopédicos: ${e.toString()}'),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém um banco ortopédico por ID
  AsyncResult<OrthopedicBank> getOrthopedicBank(String bankId) async {
    try {
      debugPrint('Getting orthopedic bank: $bankId');

      // Verifica se já existe no estado atual
      try {
        final existingBank = _state.banks.firstWhere(
          (bank) => bank.id == bankId,
        );
        debugPrint('Returning existing bank from state: ${existingBank.name}');
        return Success(existingBank);
      } catch (e) {
        // Banco não encontrado no estado, busca no repositório
      }

      final result = await _repository.getOrthopedicBank(bankId);

      return result.fold(
        (success) {
          // Atualiza o estado local com o banco carregado
          final updatedBanks = List<OrthopedicBank>.from(_state.banks);
          updatedBanks.removeWhere((bank) => bank.id == bankId);
          updatedBanks.add(success);

          _updateState(
            _state.copyWith(banks: updatedBanks, lastUpdated: DateTime.now()),
          );

          debugPrint('Orthopedic bank loaded: ${success.name}');
          return Success(success);
        },
        (failure) {
          debugPrint('Error getting orthopedic bank: $failure');
          return Failure(failure);
        },
      );
    } catch (e) {
      debugPrint('Error in getOrthopedicBank: $e');
      return Failure(
        Exception('Erro ao carregar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Cria um novo banco ortopédico
  AsyncResult<OrthopedicBank> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    try {
      debugPrint('Creating orthopedic bank: ${request.name}');

      // Atualização otimista - cria um banco temporário
      final tempBank = OrthopedicBank(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        city: request.city,
        createdAt: DateTime.now(),
      );

      final optimisticBanks = [..._state.banks, tempBank];
      _updateState(_state.copyWith(banks: optimisticBanks));

      final result = await _repository.createOrthopedicBank(request);

      return result.fold(
        (success) {
          // Remove o banco temporário e adiciona o real
          final updatedBanks =
              _state.banks.where((bank) => bank.id != tempBank.id).toList();
          updatedBanks.add(success);

          _updateState(
            _state.copyWith(banks: updatedBanks, lastUpdated: DateTime.now()),
          );

          debugPrint('Orthopedic bank created successfully: ${success.name}');
          return Success(success);
        },
        (failure) {
          // Reverte a atualização otimista
          final revertedBanks =
              _state.banks.where((bank) => bank.id != tempBank.id).toList();
          _updateState(_state.copyWith(banks: revertedBanks));

          debugPrint('Error creating orthopedic bank: $failure');
          return Failure(failure);
        },
      );
    } catch (e) {
      debugPrint('Error in createOrthopedicBank: $e');
      return Failure(
        Exception('Erro ao criar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Atualiza um banco ortopédico
  AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    try {
      debugPrint('Updating orthopedic bank: $bankId');

      // Guarda o estado original para reverter se necessário
      final originalBanks = List<OrthopedicBank>.from(_state.banks);

      // Atualização otimista
      final bankIndex = _state.banks.indexWhere((bank) => bank.id == bankId);
      if (bankIndex != -1) {
        final currentBank = _state.banks[bankIndex];
        final updatedBank = currentBank.copyWith(
          name: request.name ?? currentBank.name,
          city: request.city ?? currentBank.city,
        );

        final optimisticBanks = List<OrthopedicBank>.from(_state.banks);
        optimisticBanks[bankIndex] = updatedBank;
        _updateState(_state.copyWith(banks: optimisticBanks));
      }

      final result = await _repository.updateOrthopedicBank(bankId, request);

      return result.fold(
        (success) {
          // Atualiza com os dados reais do servidor
          final updatedBanks =
              _state.banks
                  .map((bank) => bank.id == bankId ? success : bank)
                  .toList();

          _updateState(
            _state.copyWith(banks: updatedBanks, lastUpdated: DateTime.now()),
          );

          debugPrint('Orthopedic bank updated successfully: ${success.name}');
          return Success(success);
        },
        (failure) {
          // Reverte a atualização otimista
          _updateState(_state.copyWith(banks: originalBanks));

          debugPrint('Error updating orthopedic bank: $failure');
          return Failure(failure);
        },
      );
    } catch (e) {
      debugPrint('Error in updateOrthopedicBank: $e');
      return Failure(
        Exception('Erro ao atualizar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Deleta um banco ortopédico
  AsyncResult<void> deleteOrthopedicBank(String bankId) async {
    try {
      debugPrint('Deleting orthopedic bank: $bankId');

      // Guarda o banco que será removido para reverter se necessário
      final bankToDelete = _state.banks.firstWhere(
        (bank) => bank.id == bankId,
        orElse: () => throw StateError('Bank not found'),
      );

      // Atualização otimista - remove o banco
      final optimisticBanks =
          _state.banks.where((bank) => bank.id != bankId).toList();
      _updateState(_state.copyWith(banks: optimisticBanks));

      final result = await _repository.deleteOrthopedicBank(bankId);

      return result.fold(
        (success) {
          _updateState(_state.copyWith(lastUpdated: DateTime.now()));
          debugPrint('Orthopedic bank deleted successfully: $bankId');
          return Success(());
        },
        (failure) {
          // Reverte a atualização otimista
          final revertedBanks = [..._state.banks, bankToDelete];
          _updateState(_state.copyWith(banks: revertedBanks));

          debugPrint('Error deleting orthopedic bank: $failure');
          return Failure(failure);
        },
      );
    } catch (e) {
      debugPrint('Error in deleteOrthopedicBank: $e');
      return Failure(
        Exception('Erro ao deletar banco ortopédico: ${e.toString()}'),
      );
    }
  }

  /// Limpa o cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCache();
      _updateState(const OrthopedicBanksState());
      debugPrint('Orthopedic banks cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Recarrega dados do servidor
  Future<void> refresh() async {
    await loadOrthopedicBanks(forceRefresh: true);
  }

  /// Atualiza o estado e notifica listeners
  void _updateState(OrthopedicBanksState newState) {
    _state = newState;
    notifyListeners();
    _stateController?.add(_state);
  }

  /// Define estado de loading
  void _setLoading(bool loading) {
    _updateState(_state.copyWith(isLoading: loading));
  }

  /// Busca bancos por nome ou cidade
  List<OrthopedicBank> searchBanks(String query) {
    if (query.isEmpty) return _state.banks;

    final lowerQuery = query.toLowerCase();
    return _state.banks.where((bank) {
      return bank.name.toLowerCase().contains(lowerQuery) ||
          bank.city.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Obtém banco por ID do estado atual (sincrono)
  OrthopedicBank? getBankById(String bankId) {
    try {
      return _state.banks.firstWhere((bank) => bank.id == bankId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _stateController?.close();
    super.dispose();
  }
}
