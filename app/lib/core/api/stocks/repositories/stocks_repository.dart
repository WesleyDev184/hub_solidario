import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/stocks/models/stocks_models.dart';
import 'package:result_dart/result_dart.dart';

/// Repository para operações de stocks na API
class StocksRepository {
  final ApiClient _apiClient;

  const StocksRepository(this._apiClient);

  /// Busca todos os stocks
  AsyncResult<List<Stock>> getStocks() async {
    try {
      final result = await _apiClient.get('/stocks', useAuth: true);

      return result.fold((data) {
        try {
          final response = StockListResponse.fromJson(data);
          if (response.success) {
            return Success(response.data);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao buscar stocks'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos stocks: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca um stock por ID
  AsyncResult<Stock> getStock(String stockId) async {
    try {
      final result = await _apiClient.get('/stocks/$stockId', useAuth: true);

      return result.fold((data) {
        try {
          final response = StockResponse.fromJson(data);
          if (response.success && response.data != null) {
            return Success(response.data!);
          } else {
            return Failure(
              Exception(response.message ?? 'Stock não encontrado'),
            );
          }
        } catch (e) {
          return Failure(Exception('Erro ao processar resposta do stock: $e'));
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Busca stocks por banco ortopédico
  AsyncResult<List<Stock>> getStocksByOrthopedicBank(
    String orthopedicBankId,
  ) async {
    try {
      final result = await _apiClient.get(
        '/stocks/orthopedic-bank/$orthopedicBankId',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = StockListResponse.fromJson(data);
          if (response.success) {
            return Success(response.data);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao buscar stocks do banco'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta dos stocks: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Cria um novo stock
  AsyncResult<Stock> createStock(CreateStockRequest request) async {
    try {
      // Se tem imagem, usa multipart
      if (request.imageFile != null || request.imageBytes != null) {
        final result = await _apiClient.postMultipart(
          '/stocks',
          request.toJson(),
          file: request.imageFile,
          bytes: request.imageBytes,
          fileName: request.imageFileName,
          fileFieldName: 'imageFile',
          useAuth: true,
        );

        return result.fold((data) {
          try {
            // A API retorna uma estrutura { success: bool, data: Stock, message: string }
            final stockData = data['data'] as Map<String, dynamic>;
            final response = Stock.fromJson(stockData);

            return Success(response);
          } catch (e) {
            return Failure(
              Exception('Erro ao processar resposta da criação: $e'),
            );
          }
        }, (error) => Failure(error));
      } else {
        // Sem imagem, usa POST normal
        final result = await _apiClient.post(
          '/stocks',
          request.toJson(),
          useAuth: true,
        );

        return result.fold((data) {
          try {
            // A API retorna uma estrutura { success: bool, data: Stock, message: string }
            final stockData = data['data'] as Map<String, dynamic>;
            final response = Stock.fromJson(stockData);

            return Success(response);
          } catch (e) {
            return Failure(
              Exception('Erro ao processar resposta da criação: $e'),
            );
          }
        }, (error) => Failure(error));
      }
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Atualiza um stock existente
  AsyncResult<Stock> updateStock(
    String stockId,
    UpdateStockRequest request,
  ) async {
    try {
      // Sempre usa multipart pois a API espera form-data
      final result = await _apiClient.patchMultipart(
        '/stocks/$stockId',
        request.toJson(),
        file: request.imageFile,
        bytes: request.imageBytes,
        fileName: request.imageFileName,
        fileFieldName: 'imageFile',
        useAuth: true,
      );

      return result.fold((data) {
        try {
          final response = UpdateStockResponse.fromJson(data);
          if (response.success) {
            // Se não há dados do stock atualizado, criar um stock básico com o ID
            if (response.data != null) {
              return Success(response.data!);
            } else {
              // Cria um stock básico com ID para indicar sucesso
              final updatedStock = Stock(
                id: stockId,
                title: request.title ?? 'Categoria atualizada',
                imageUrl: '',
                maintenanceQtd: 0,
                availableQtd: 0,
                borrowedQtd: 0,
                totalQtd: 0,
                orthopedicBankId: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              return Success(updatedStock);
            }
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao atualizar stock'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da atualização: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }

  /// Deleta um stock
  AsyncResult<bool> deleteStock(String stockId) async {
    try {
      final result = await _apiClient.delete('/stocks/$stockId', useAuth: true);

      return result.fold((data) {
        try {
          final response = DeleteStockResponse.fromJson(data);
          if (response.success) {
            return Success(true);
          } else {
            return Failure(
              Exception(response.message ?? 'Erro ao deletar stock'),
            );
          }
        } catch (e) {
          return Failure(
            Exception('Erro ao processar resposta da deleção: $e'),
          );
        }
      }, (error) => Failure(error));
    } catch (e) {
      return Failure(Exception('Erro na comunicação com a API: $e'));
    }
  }
}
