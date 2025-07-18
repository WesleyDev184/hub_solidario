import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

import '../models/orthopedic_banks_models.dart';
import '../repositories/orthopedic_banks_repository.dart';
import '../services/orthopedic_banks_cache_service.dart';

class OrthopedicBanksController extends GetxController {
  final OrthopedicBanksRepository repository;
  final OrthopedicBanksCacheService cacheService;

  final RxList<OrthopedicBank> _banks = <OrthopedicBank>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString? _error = RxString('');

  List<OrthopedicBank> get banks => _banks.toList();
  bool get isLoading => _isLoading.value;
  String? get error => _error?.value;

  OrthopedicBanksController(this.repository, this.cacheService);

  @override
  void onInit() {
    super.onInit();
    loadOrthopedicBanks();
  }

  AsyncResult<List<OrthopedicBank>> loadOrthopedicBanks({
    bool forceRefresh = false,
  }) async {
    _setLoading(true);
    try {
      if (!forceRefresh) {
        final cachedState = await cacheService.loadOrthopedicBanksState();
        if (cachedState.isNotEmpty) {
          _banks.value = cachedState;
          _setLoading(false);
          return Success(cachedState);
        }
      }
      final result = await repository.getOrthopedicBanks(
        forceRefresh: forceRefresh,
      );
      return await result.fold(
        (banks) async {
          _banks.value = banks;
          await cacheService.saveOrthopedicBanksState(banks);
          _setLoading(false);
          return Success(banks);
        },
        (error) async {
          _error?.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error?.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao carregar bancos ortopédicos: $e'));
    }
  }

  AsyncResult<String> createOrthopedicBank(
    CreateOrthopedicBankRequest request,
  ) async {
    _setLoading(true);
    try {
      final result = await repository.createOrthopedicBank(request);
      return await result.fold(
        (bank) async {
          _banks.add(bank);
          await cacheService.saveOrthopedicBankState(bank);
          _setLoading(false);
          return Success(bank.id);
        },
        (error) async {
          _error?.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error?.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao criar banco ortopédico: $e'));
    }
  }

  AsyncResult<OrthopedicBank> updateOrthopedicBank(
    String bankId,
    UpdateOrthopedicBankRequest request,
  ) async {
    _setLoading(true);
    try {
      final result = await repository.updateOrthopedicBank(bankId, request);
      return await result.fold(
        (bank) async {
          _banks.assignAll(
            _banks.map((b) => b.id == bank.id ? bank : b).toList(),
          );
          await cacheService.updateOrthopedicBankState(bank);
          _setLoading(false);
          return Success(bank);
        },
        (error) async {
          _error?.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error?.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao atualizar banco ortopédico: $e'));
    }
  }

  AsyncResult<bool> deleteOrthopedicBank(String bankId) async {
    _setLoading(true);
    try {
      final result = await repository.deleteOrthopedicBank(bankId);
      return await result.fold(
        (success) async {
          if (success) {
            _banks.assignAll(_banks.where((b) => b.id != bankId).toList());
            await cacheService.removeOrthopedicBankState(bankId);
          }
          _setLoading(false);
          return Success(success);
        },
        (error) async {
          _error?.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error?.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao deletar banco ortopédico: $e'));
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading.value != loading) {
      _isLoading.value = loading;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
