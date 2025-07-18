import 'package:app/core/api/auth/auth.dart';
import 'package:app/core/api/stocks/models/stocks_models.dart';
import 'package:app/core/api/stocks/repositories/stocks_repository.dart';
import 'package:app/core/api/stocks/services/stocks_cache_service.dart';
import 'package:get/get.dart';
import 'package:result_dart/result_dart.dart';

/// Controller para gerenciar operações de stocks
class StocksController {
  final StocksRepository _repository;
  final StocksCacheService _cacheService;
  final authController = Get.find<AuthController>();

  bool _isLoading = false;
  String? _error;

  StocksController(this._repository, this._cacheService);

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro, se houver
  String? get error => _error;

  /// Busca stocks por banco ortopédico
  AsyncResult<List<Stock>> loadStocksByOrthopedicBank({
    bool forceRefresh = false,
  }) async {
    try {
      _isLoading = true;

      final orthopedicBankId = authController.getOrthopedicBankId;
      if (orthopedicBankId == null) {
        _isLoading = false;
        return Failure(
          Exception('Usuário não possui banco ortopédico associado.'),
        );
      }

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

  /// Cria um novo stock
  AsyncResult<String> createStock(CreateStockRequest request) async {
    try {
      final result = await _repository.createStock(request);

      return result.fold((stock) {
        _cacheService.cacheStock(stock);

        return Success(stock.id);
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
        // Atualiza o cache
        _cacheService.cacheStock(stock);

        return Success(stock);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Atualiza o cache de um stock
  Future<void> cacheStock(Stock stock) async {
    try {
      await _cacheService.cacheStock(stock);
    } catch (e) {
      throw Exception('Erro ao atualizar cache: $e');
    }
  }

  /// Deleta um stock
  AsyncResult<bool> deleteStock(String stockId) async {
    try {
      final result = await _repository.deleteStock(stockId);

      return result.fold((success) {
        if (success) {
          final orthopedicBankId = authController.getOrthopedicBankId;
          if (orthopedicBankId != null) {
            _cacheService.removeStockFromCache(
              orthopedicBankId,
              stockId,
            );
          }
        }

        return Success(success);
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro inesperado: $e'));
    }
  }

  /// Limpa todos os dados locais e cache
  Future<void> clearData() async {
    _error = null;
    _isLoading = false;
    await _cacheService.clearCache();
  }
}
