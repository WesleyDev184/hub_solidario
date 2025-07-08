import 'package:project_rotary/core/api/stocks/models/stocks_models.dart';
import 'package:project_rotary/core/api/stocks/repositories/stocks_repository.dart';
import 'package:project_rotary/core/api/stocks/services/stocks_cache_service.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de stocks
class StocksController {
  final StocksRepository _repository;
  final StocksCacheService _cacheService;

  List<Stock> _stocks = [];
  bool _isLoading = false;
  String? _error;

  StocksController(this._repository, this._cacheService);

  /// Lista de stocks atual
  List<Stock> get stocks => List.unmodifiable(_stocks);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Verifica se tem dados carregados
  bool get hasData => _stocks.isNotEmpty;

  /// Carrega todos os stocks
  AsyncResult<List<Stock>> loadStocks({bool forceRefresh = false}) async {
    if (_isLoading) {
      return Success(_stocks);
    }

    _isLoading = true;
    _error = null;

    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedStocks = await _cacheService.getCachedStocks();
        if (cachedStocks != null) {
          _stocks = cachedStocks;
          _isLoading = false;
          return Success(_stocks);
        }
      }

      // Busca da API
      final result = await _repository.getStocks();

      return result.fold(
        (stocks) {
          _stocks = stocks;
          _isLoading = false;

          // Salva no cache
          _cacheService.cacheStocks(stocks);

          return Success(stocks);
        },
        (error) {
          _error = error.toString();
          _isLoading = false;

          // Se falhar e não tiver cache, usa lista vazia
          if (_stocks.isEmpty) {
            return Failure(error);
          }

          // Se falhar mas tiver cache, retorna o cache
          return Success(_stocks);
        },
      );
    } catch (e) {
      _error = 'Erro inesperado: $e';
      _isLoading = false;
      return Failure(Exception(_error!));
    }
  }

  /// Busca stocks por banco ortopédico
  AsyncResult<List<Stock>> loadStocksByOrthopedicBank(
    String orthopedicBankId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedStocks = await _cacheService.getCachedStocksByBank(
          orthopedicBankId,
        );
        if (cachedStocks != null) {
          return Success(cachedStocks);
        }
      }

      // Busca da API
      final result = await _repository.getStocksByOrthopedicBank(
        orthopedicBankId,
      );

      return result.fold((stocks) {
        // Salva no cache
        _cacheService.cacheStocksByBank(orthopedicBankId, stocks);

        return Success(stocks);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca um stock por ID
  AsyncResult<Stock> getStock(
    String stockId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Verifica cache primeiro, se não for refresh forçado
      if (!forceRefresh) {
        final cachedStock = await _cacheService.getCachedStock(stockId);
        if (cachedStock != null) {
          return Success(cachedStock);
        }
      }

      // Busca da API
      final result = await _repository.getStock(stockId);

      return result.fold((stock) {
        // Salva no cache
        _cacheService.cacheStock(stock);

        return Success(stock);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Cria um novo stock
  AsyncResult<String> createStock(CreateStockRequest request) async {
    try {
      final result = await _repository.createStock(request);

      return result.fold((stockId) {
        // Limpa o cache para forçar recarregamento
        _cacheService.clearCache();

        // Se o stock foi criado com sucesso, recarrega a lista
        loadStocks(forceRefresh: true);

        return Success(stockId);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza um stock existente
  AsyncResult<Stock> updateStock(
    String stockId,
    UpdateStockRequest request,
  ) async {
    try {
      final result = await _repository.updateStock(stockId, request);

      return result.fold((stock) {
        // Atualiza o stock na lista local
        final index = _stocks.indexWhere((s) => s.id == stockId);
        if (index != -1) {
          _stocks[index] = stock;
        }

        // Atualiza o cache
        _cacheService.cacheStock(stock);

        return Success(stock);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Deleta um stock
  AsyncResult<bool> deleteStock(String stockId) async {
    try {
      final result = await _repository.deleteStock(stockId);

      return result.fold((success) {
        if (success) {
          // Remove o stock da lista local
          _stocks.removeWhere((stock) => stock.id == stockId);

          // Remove do cache
          _cacheService.removeStockFromCache(stockId);
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Busca stocks por título (busca local)
  List<Stock> searchStocksByTitle(String query) {
    if (query.isEmpty) return _stocks;

    return _stocks
        .where(
          (stock) => stock.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Filtra stocks por disponibilidade
  List<Stock> getAvailableStocks() {
    return _stocks.where((stock) => stock.hasAvailableItems).toList();
  }

  /// Filtra stocks por banco ortopédico
  List<Stock> getStocksByBank(String orthopedicBankId) {
    return _stocks
        .where((stock) => stock.orthopedicBankId == orthopedicBankId)
        .toList();
  }

  /// Obtém estatísticas dos stocks
  Map<String, int> getStocksStatistics() {
    int totalStocks = _stocks.length;
    int availableStocks = _stocks.where((s) => s.hasAvailableItems).length;
    int totalItems = _stocks.fold(0, (sum, stock) => sum + stock.totalQtd);
    int availableItems = _stocks.fold(
      0,
      (sum, stock) => sum + stock.availableQtd,
    );
    int borrowedItems = _stocks.fold(
      0,
      (sum, stock) => sum + stock.borrowedQtd,
    );
    int maintenanceItems = _stocks.fold(
      0,
      (sum, stock) => sum + stock.maintenanceQtd,
    );

    return {
      'totalStocks': totalStocks,
      'availableStocks': availableStocks,
      'totalItems': totalItems,
      'availableItems': availableItems,
      'borrowedItems': borrowedItems,
      'maintenanceItems': maintenanceItems,
    };
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _stocks.clear();
    _error = null;
    _isLoading = false;
    await _cacheService.clearCache();
  }

  /// Força atualização dos dados
  AsyncResult<List<Stock>> refreshStocks() async {
    return loadStocks(forceRefresh: true);
  }

  /// Verifica se um stock específico está disponível
  bool isStockAvailable(String stockId) {
    final stock = _stocks.firstWhere(
      (s) => s.id == stockId,
      orElse: () => throw Exception('Stock não encontrado'),
    );
    return stock.hasAvailableItems;
  }

  /// Obtém a quantidade disponível de um stock
  int getAvailableQuantity(String stockId) {
    final stock = _stocks.firstWhere(
      (s) => s.id == stockId,
      orElse: () => throw Exception('Stock não encontrado'),
    );
    return stock.availableQtd;
  }
}
