import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/api/stocks/models/items_models.dart';
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
  set error(String? value) {
    _error.value = value ?? '';
  }

  RxList<Stock> get allStocks => _stocks;

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
      return result.fold((list) async {
        await cacheService.cacheStocksByBank(orthopedicBankId, list);
        _stocks.assignAll(list);
        return Success(list);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  AsyncResult<Stock> getStockById(String stockId) async {
    try {
      _isLoading.value = true;
      if (_stocks.isNotEmpty) {
        final stock = _stocks.firstWhereOrNull((s) => s.id == stockId);
        if (stock != null && stock.items?.isNotEmpty == true) {
          _isLoading.value = false;
          return Success(stock);
        }
      }

      final result = await repository.getStock(stockId);
      _isLoading.value = false;
      return result.fold((stock) async {
        await cacheService.cacheStock(stock);
        updateStockInList(stock);
        return Success(stock);
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
      return result.fold((stock) async {
        await cacheService.cacheStock(stock);
        _stocks.add(stock);
        return Success(stock.id);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// pega os items de um estoque específico
  AsyncResult<List<Item>> getItemsByStockId(String stockId) async {
    try {
      _isLoading.value = true;
      final stock = _stocks.firstWhereOrNull((s) => s.id == stockId);
      if (stock != null && stock.items?.isNotEmpty == true) {
        _isLoading.value = false;
        return Success(stock.items!);
      }

      final result = await getStockById(stockId);
      return result.fold(
        (stock) {
          _isLoading.value = false;
          return Success(stock.items ?? []);
        },
        (error) {
          _isLoading.value = false;
          return Failure(error);
        },
      );
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
      return result.fold((stock) async {
        await cacheService.cacheStock(stock);
        updateStockInList(stock);
        return Success(stock);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  AsyncResult<bool> deleteStock(String stockId) async {
    try {
      _isLoading.value = true;
      final result = await repository.deleteStock(stockId);
      _isLoading.value = false;
      return await result.fold((success) async {
        if (success) {
          final orthopedicBankId = authController.getOrthopedicBankId;
          if (orthopedicBankId != null) {
            _stocks.removeWhere((stock) => stock.id == stockId);
            // Atualiza o cache completo após remover
            await cacheService.cacheStocksByBank(orthopedicBankId, _stocks);
          }
        }
        return Success(success);
      }, (error) async => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  void updateStockInList(Stock stock) {
    final index = _stocks.indexWhere((s) => s.id == stock.id);
    if (index != -1) {
      final savedStock = _stocks[index];
      // Se o stock já salvo tem itens, mantém esses itens
      final updatedStock =
          (savedStock.items != null && savedStock.items!.isNotEmpty)
          ? stock.copyWith(items: savedStock.items)
          : stock.copyWith();
      _stocks[index] = updatedStock; // garante nova referência
    } else {
      _stocks.add(stock);
    }
  }

  /// Cria um novo item no estoque
  AsyncResult<Item> createItem(CreateItemRequest request) async {
    try {
      _isLoading.value = true;
      final result = await repository.createItem(request);
      _isLoading.value = false;
      return result.fold((item) async {
        final stockTemp = _stocks.firstWhereOrNull(
          (s) => s.id == request.stockId,
        );

        if (stockTemp != null) {
          // Atualiza o stock na lista com o novo item
          final updatedStock = stockTemp.copyWith(
            items: [...?stockTemp.items, item],
          );
          _stocks[_stocks.indexOf(stockTemp)] = updatedStock;
          await cacheService.cacheStock(updatedStock);
        }

        return Success(item);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um item no estoque e ajusta os contadores de status
  AsyncResult<Item> updateItem(String itemId, UpdateItemRequest request) async {
    try {
      _isLoading.value = true;
      final result = await repository.updateItem(itemId, request);
      _isLoading.value = false;
      return result.fold((item) async {
        final stockTemp = _stocks.firstWhereOrNull(
          (s) => s.items?.any((i) => i.id == itemId) ?? false,
        );
        if (stockTemp != null) {
          final updatedStock = updateStockItemAndCounters(
            stock: stockTemp,
            item: item,
            itemId: itemId,
          );
          _stocks[_stocks.indexOf(stockTemp)] = updatedStock;
          await cacheService.cacheStock(updatedStock);
        }
        return Success(item);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um item do estoque e ajusta os contadores de status
  AsyncResult<bool> deleteItem(String itemId, String stockId) async {
    try {
      _isLoading.value = true;
      final result = await repository.deleteItem(itemId);
      _isLoading.value = false;
      return result.fold((success) async {
        if (success) {
          final stockTemp = _stocks.firstWhereOrNull((s) => s.id == stockId);
          if (stockTemp != null) {
            // Cria um item fake apenas para passar o tipo para a função
            final fakeItem = stockTemp.items?.firstWhere((i) => i.id == itemId);
            if (fakeItem != null) {
              final updatedStock = updateStockItemAndCounters(
                stock: stockTemp,
                item: fakeItem,
                itemId: itemId,
                isDelete: true,
              );
              _stocks[_stocks.indexOf(stockTemp)] = updatedStock;
              await cacheService.cacheStock(updatedStock);
            }
          }
        }
        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza o item apos um empréstimo ou devolução
  AsyncResult<bool> updateItemAfterBorrow(String itemId, String stockId) async {
    try {
      _isLoading.value = true;
      final stock = _stocks.firstWhereOrNull((s) => s.id == stockId);
      if (stock != null) {
        final item = stock.items?.firstWhereOrNull((i) => i.id == itemId);
        if (item != null) {
          final itemTemp = item.copyWith(
            status: item.status == ItemStatus.available
                ? ItemStatus.unavailable
                : ItemStatus.available,
          );

          final updatedStock = updateStockItemAndCounters(
            stock: stock,
            item: itemTemp,
            itemId: itemId,
          );

          _stocks[_stocks.indexOf(stock)] = updatedStock;
          await cacheService.cacheStock(updatedStock);

          _isLoading.value = false;
          return Success(true);
        }
        _isLoading.value = false;
        return Failure(Exception('Item não encontrado'));
      }
      _isLoading.value = false;
      return Failure(Exception('Estoque não encontrado'));
    } catch (e) {
      _isLoading.value = false;
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza os itens e contadores de status de um estoque ao modificar um item
  Stock updateStockItemAndCounters({
    required Stock stock,
    required Item item,
    required String itemId,
    bool isDelete = false,
  }) {
    // Descobre o item antigo para saber o status anterior
    final oldItem = stock.items?.firstWhereOrNull((i) => i.id == itemId);
    final oldStatus = oldItem?.status;
    final newStatus = item.status;

    // Atualiza o item na lista
    final updatedItems = isDelete
        ? stock.items?.where((i) => i.id != itemId).toList()
        : stock.items?.map((i) => i.id == itemId ? item : i).toList();

    // Atualiza os contadores de status
    int availableQtd = stock.availableQtd;
    int maintenanceQtd = stock.maintenanceQtd;
    int borrowedQtd = stock.borrowedQtd;
    int totalQtd = stock.totalQtd;

    if (isDelete) {
      if (oldStatus == ItemStatus.available) {
        availableQtd -= 1;
      } else if (oldStatus == ItemStatus.maintenance) {
        maintenanceQtd -= 1;
      }
      totalQtd -= 1;
    } else if (oldStatus != null && oldStatus != newStatus) {
      // Remove do status antigo
      if (oldStatus == ItemStatus.available) {
        availableQtd -= 1;
      } else if (oldStatus == ItemStatus.maintenance) {
        maintenanceQtd -= 1;
      } else if (oldStatus == ItemStatus.unavailable) {
        borrowedQtd -= 1;
      }
      // Adiciona ao novo status
      if (newStatus == ItemStatus.available) {
        availableQtd += 1;
      } else if (newStatus == ItemStatus.maintenance) {
        maintenanceQtd += 1;
      } else if (newStatus == ItemStatus.unavailable) {
        borrowedQtd += 1;
      }
    }

    return stock.copyWith(
      items: updatedItems,
      availableQtd: availableQtd,
      maintenanceQtd: maintenanceQtd,
      borrowedQtd: borrowedQtd,
      totalQtd: totalQtd,
    );
  }

  Future<void> clearData() async {
    _error.value = '';
    _isLoading.value = false;
    _stocks.clear();
    await cacheService.clearCache();
  }
}
