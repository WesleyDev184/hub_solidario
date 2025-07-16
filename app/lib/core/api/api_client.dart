import 'dart:convert';
import 'dart:io';

import 'package:app/core/api/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:result_dart/result_dart.dart';

/// Cliente HTTP para realizar chamadas à API Rotary
class ApiClient {
  final http.Client _client;
  String? _apiKey;
  String? _accessToken;

  /// Callback para logout automático em caso de erro 401
  Function()? _onUnauthorized;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Define a API Key para autenticação
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  /// Define o token de acesso para autenticação Bearer
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Remove o token de acesso
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Define o callback para logout automático em caso de erro 401
  void setOnUnauthorizedCallback(Function()? callback) {
    _onUnauthorized = callback;
  }

  /// Headers para requisições
  Map<String, String> _getHeaders({bool useAuth = false}) {
    Map<String, String> headers = Map.from(ApiConfig.defaultHeaders);

    // Sempre adiciona o x-api-key header para todas as requisições
    headers['x-api-key'] = 'your_api_key_here';

    // Se uma API Key específica foi configurada, usa ela ao invés do valor padrão
    if (_apiKey != null) {
      headers['x-api-key'] = _apiKey!;
    }

    // Adiciona autenticação Bearer se necessário
    if (useAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Realiza uma requisição GET
  AsyncResult<Map<String, dynamic>> get(
    String endpoint, {
    bool useAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);

      debugPrint('GET $uri');

      final response = await _client.get(
        uri,
        headers: _getHeaders(useAuth: useAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      return Failure(Exception('Erro na requisição GET: ${e.toString()}'));
    }
  }

  /// Realiza uma requisição POST
  AsyncResult<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool useAuth = false,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      debugPrint('POST $uri');
      debugPrint('Body: ${jsonEncode(data)}');

      final response = await _client.post(
        uri,
        headers: _getHeaders(useAuth: useAuth),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return Failure(Exception('Erro na requisição POST: ${e.toString()}'));
    }
  }

  /// Realiza uma requisição PATCH
  AsyncResult<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool useAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      debugPrint('PATCH $uri');
      debugPrint('Body: ${jsonEncode(data)}');

      final response = await _client.patch(
        uri,
        headers: _getHeaders(useAuth: useAuth),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return Failure(Exception('Erro na requisição PATCH: ${e.toString()}'));
    }
  }

  /// Realiza uma requisição PATCH com multipart/form-data
  AsyncResult<Map<String, dynamic>> patchMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    File? file,
    Uint8List? bytes,
    String? fileName,
    String fileFieldName = 'imageFile',
    bool useAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('PATCH Multipart $uri');

      var request = http.MultipartRequest('PATCH', uri);

      // Adiciona headers de autenticação
      final headers = _getHeaders(useAuth: useAuth);
      request.headers.addAll(headers);

      // Remove content-type para deixar o http definir com boundary
      request.headers.remove('Content-Type');

      // Adiciona campos de texto
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Adiciona arquivo se fornecido
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            filename: fileName ?? 'image.jpg',
          ),
        );
      } else if (bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            bytes,
            filename: fileName ?? 'image.jpg',
          ),
        );
      }

      debugPrint('Multipart fields: ${request.fields}');
      debugPrint('Multipart files: ${request.files.map((f) => f.filename)}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return Failure(
        Exception('Erro na requisição PATCH Multipart: ${e.toString()}'),
      );
    }
  }

  /// Realiza uma requisição DELETE
  AsyncResult<Map<String, dynamic>> delete(
    String endpoint, {
    bool useAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);

      debugPrint('DELETE $uri');

      final response = await _client.delete(
        uri,
        headers: _getHeaders(useAuth: useAuth),
      );

      return _handleResponse(response);
    } catch (e) {
      return Failure(Exception('Erro na requisição DELETE: ${e.toString()}'));
    }
  }

  /// Realiza uma requisição POST com multipart/form-data
  AsyncResult<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> fields, {
    File? file,
    Uint8List? bytes,
    String? fileName,
    String fileFieldName = 'imageFile',
    bool useAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('POST Multipart $uri');

      var request = http.MultipartRequest('POST', uri);

      // Adiciona headers de autenticação
      final headers = _getHeaders(useAuth: useAuth);
      request.headers.addAll(headers);

      // Remove content-type para deixar o http definir com boundary
      request.headers.remove('Content-Type');

      // Adiciona campos de texto
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Adiciona arquivo se fornecido
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            filename: fileName ?? 'image.jpg',
          ),
        );
      } else if (bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            bytes,
            filename: fileName ?? 'image.jpg',
          ),
        );
      }

      debugPrint('Multipart fields: ${request.fields}');
      debugPrint('Multipart files: ${request.files.map((f) => f.filename)}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return Failure(
        Exception('Erro na requisição POST Multipart: ${e.toString()}'),
      );
    }
  }

  /// Constrói a URI completa
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final uri = baseUri.replace(path: endpoint, queryParameters: queryParams);
    return uri;
  }

  /// Trata a resposta da requisição
  AsyncResult<Map<String, dynamic>> _handleResponse(
    http.Response response,
  ) async {
    try {
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Verifica se a resposta é bem-sucedida
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Tenta decodificar o JSON
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return Success(data);
        } else {
          // Resposta vazia mas bem-sucedida
          return Success(<String, dynamic>{});
        }
      } else {
        // Erro HTTP
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return Failure(Exception('Erro ao processar resposta: ${e.toString()}'));
    }
  }

  /// Trata respostas de erro
  AsyncResult<Map<String, dynamic>> _handleErrorResponse(
    http.Response response,
  ) async {
    String errorMessage;

    try {
      // Tenta extrair a mensagem de erro do body
      if (response.body.isNotEmpty) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;

        // Verifica diferentes formatos de erro baseados na documentação OpenAPI
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'] as String;
        } else if (errorData.containsKey('title')) {
          errorMessage = errorData['title'] as String;
        } else if (errorData.containsKey('detail')) {
          errorMessage = errorData['detail'] as String;
        } else {
          errorMessage = 'Erro na requisição: ${response.statusCode}';
        }
      } else {
        errorMessage = _getStatusCodeMessage(response.statusCode);
      }
    } catch (e) {
      errorMessage = _getStatusCodeMessage(response.statusCode);
    }

    // Se for erro 401 (não autorizado), executa logout automático
    if (response.statusCode == 401 && _onUnauthorized != null) {
      debugPrint('Erro 401 detectado - executando logout automático');
      _onUnauthorized!();
    }

    return Failure(HttpException(errorMessage, uri: response.request?.url));
  }

  /// Obtém mensagem de erro baseada no código de status
  String _getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Dados inválidos fornecidos';
      case 401:
        return 'Credenciais inválidas';
      case 403:
        return 'Acesso negado';
      case 404:
        return 'Recurso não encontrado';
      case 409:
        return 'Conflito - recurso já existe';
      case 500:
        return 'Erro interno do servidor';
      default:
        return 'Erro na requisição: $statusCode';
    }
  }

  /// Fecha o cliente HTTP
  void dispose() {
    _client.close();
  }
}
