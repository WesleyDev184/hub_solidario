import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/hubs/models/hubs_models.dart';
import 'package:app/core/api/hubs/repositories/hubs_repository.dart';
import 'package:app/core/api/hubs/services/hubs_cache_service.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

class HubsController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final HubsRepository repository;
  final HubsCacheService cacheService;

  final RxList<Hub> _hubs = <Hub>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = RxString('');

  List<Hub> get hubs => _hubs.toList();
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  HubsController(this.repository, this.cacheService);

  @override
  void onInit() async {
    super.onInit();

    // Observa mudanças no estado de autenticação
    ever(authController.stateRx, (authState) async {
      if (authState.isAuthenticated) {
        await loadHubs();
      } else {
        clearData();
      }
    });

    // Carrega bancos se já estiver autenticado
    if (authController.isAuthenticated) {
      await loadHubs();
    }
  }

  AsyncResult<List<Hub>> loadHubs({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      if (!forceRefresh) {
        final cachedState = await cacheService.loadHubsState();
        if (cachedState.isNotEmpty) {
          _hubs.value = cachedState;
          _setLoading(false);
          return Success(cachedState);
        }
      }
      final result = await repository.getHubs(forceRefresh: forceRefresh);
      return await result.fold(
        (banks) async {
          _hubs.value = banks;
          await cacheService.saveHubsState(banks);
          _setLoading(false);
          return Success(banks);
        },
        (error) async {
          _error.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao carregar bancos ortopédicos: $e'));
    }
  }

  AsyncResult<String> createHub(CreateHubRequest request) async {
    _setLoading(true);
    try {
      final result = await repository.createHub(request);
      return await result.fold(
        (bank) async {
          _hubs.add(bank);
          await cacheService.saveHubState(bank);
          _setLoading(false);
          return Success(bank.id);
        },
        (error) async {
          _error.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao criar banco ortopédico: $e'));
    }
  }

  AsyncResult<Hub> updateHub(String bankId, UpdateHubRequest request) async {
    _setLoading(true);
    try {
      final result = await repository.updateHub(bankId, request);
      return await result.fold(
        (bank) async {
          _hubs.assignAll(
            _hubs.map((b) => b.id == bank.id ? bank : b).toList(),
          );
          await cacheService.updateHubState(bank);
          _setLoading(false);
          return Success(bank);
        },
        (error) async {
          _error.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao atualizar banco ortopédico: $e'));
    }
  }

  AsyncResult<bool> deleteHub(String bankId) async {
    _setLoading(true);
    try {
      final result = await repository.deleteHub(bankId);
      return await result.fold(
        (success) async {
          if (success) {
            _hubs.assignAll(_hubs.where((b) => b.id != bankId).toList());
            await cacheService.removeHubState(bankId);
          }
          _setLoading(false);
          return Success(success);
        },
        (error) async {
          _error.value = error.toString();
          _setLoading(false);
          return Failure(error);
        },
      );
    } catch (e) {
      _error.value = e.toString();
      _setLoading(false);
      return Failure(Exception('Erro ao deletar banco ortopédico: $e'));
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading.value != loading) {
      _isLoading.value = loading;
    }
  }

  void clearData() {
    _hubs.clear();
    _error.value = '';
    _isLoading.value = false;
    cacheService.clearHubsCache();
  }
}
