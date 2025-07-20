import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/stocks/models/stocks_models.dart';
import 'package:app/core/api/stocks/repositories/stocks_repository.dart';
import 'package:app/core/api/stocks/services/stocks_cache_service.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de stocks

class StocksController extends GetxController {
  late final StocksRepository repository;
  late final StocksCacheService cacheService;
  final AuthController authController = Get.find<AuthController>();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<Stock> _stocks = <Stock>[].obs;

  StocksController({required this.repository, required this.cacheService});

  bool get isLoading => _isLoading.value;
  String? get error => _error.value.isEmpty ? null : _error.value;
  List<Stock> get allStocks => _stocks.toList();

  @override
  void onInit() async {
    super.onInit();

    // Observa mudanças no estado de autenticação
    ever(authController.stateRx, (authState) async {
      if (authState.isAuthenticated) {
        await loadStocksByOrthopedicBank();
      } else {
        await clearData();
      }
    });

    // Carrega stocks se já estiver autenticado
    if (authController.isAuthenticated) {
      await loadStocksByOrthopedicBank();
    }
  }

  AsyncResult<List<Stock>> loadStocksByOrthopedicBank({
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading.value = true;
      final orthopedicBankId = authController.getOrthopedicBankId;
      if (orthopedicBankId == null) {
        _isLoading.value = false;
        return Failure(
          Exception('Usuário não possui banco ortopédico associado.'),
        );
      }
      if (!forceRefresh) {
        final cachedStocks = await cacheService.getCachedStocksByBank(
          orthopedicBankId,
        );
        if (cachedStocks != null) {
          _stocks.assignAll(cachedStocks);
          _isLoading.value = false;
          return Success(cachedStocks);
        }
      }
      final result = await repository.getStocksByOrthopedicBank(
        orthopedicBankId,
      );
      _isLoading.value = false;
      return result.fold((list) {
        cacheService.cacheStocksByBank(orthopedicBankId, list);
        _stocks.assignAll(list);
        return Success(list);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  AsyncResult<String> createStock(CreateStockRequest request) async {
    try {
      _isLoading.value = true;
      final result = await repository.createStock(request);
      _isLoading.value = false;
      return result.fold((stock) {
        cacheService.cacheStock(stock);
        _stocks.add(stock);
        return Success(stock.id);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  AsyncResult<Stock> updateStock(
    String stockId,
    UpdateStockRequest request,
  ) async {
    try {
      _isLoading.value = true;
      final result = await repository.updateStock(stockId, request);
      _isLoading.value = false;
      return result.fold((stock) {
        cacheService.cacheStock(stock);
        updateStockInList(stock);
        return Success(stock);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  Future<void> cacheStock(Stock stock) async {
    try {
      await cacheService.cacheStock(stock);
      updateStockInList(stock);
    } catch (e) {
      throw Exception('Erro ao atualizar cache: $e');
    }
  }

  AsyncResult<bool> deleteStock(String stockId) async {
    try {
      _isLoading.value = true;
      final result = await repository.deleteStock(stockId);
      _isLoading.value = false;
      return result.fold((success) {
        if (success) {
          final orthopedicBankId = authController.getOrthopedicBankId;
          if (orthopedicBankId != null) {
            _stocks.removeWhere((stock) => stock.id == stockId);
            cacheService.removeStockFromCache(orthopedicBankId, stockId);
          }
        }
        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  Future<void> clearData() async {
    _error.value = '';
    _isLoading.value = false;
    _stocks.clear();
    await cacheService.clearCache();
  }

  void updateStockInList(Stock stock) {
    final index = _stocks.indexWhere((s) => s.id == stock.id);
    if (index != -1) {
      _stocks[index] = stock;
    } else {
      _stocks.add(stock);
    }
  }
}
