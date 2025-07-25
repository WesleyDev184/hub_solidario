/// Configurações da API Rotary
class ApiConfig {
  static const String baseUrl = 'https://api.prod.hubsolidario.com';
  static const String apiKeyHeader = 'x-api-key';

  // Headers padrão
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers com API Key (quando necessário)
  static Map<String, String> headersWithApiKey(String apiKey) => {
    ...defaultHeaders,
    apiKeyHeader: apiKey,
  };

  // Headers com autenticação Bearer
  static Map<String, String> headersWithAuth(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

// Endpoints da API
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String users = '/users';
  static String userById(String id) => '/user/$id';
  static String usersByOrthopedicBank(String orthopedicBankId) =>
      '/users/orthopedic-bank/$orthopedicBankId';

  // Orthopedic Banks endpoints
  static const String orthopedicBanks = '/orthopedic-banks';
  static String orthopedicBankById(String id) => '/orthopedic-banks/$id';

  // Stocks endpoints
  static const String stocks = '/stocks';
  static String stockById(String id) => '/stocks/$id';
  static String stocksByOrthopedicBank(String orthopedicBankId) =>
      '/stocks/orthopedic-bank/$orthopedicBankId';

  // Items endpoints
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemsByStock(String stockId) => '/items/stock/$stockId';

  // Applicants endpoints
  static const String applicants = '/applicants';
  static String applicantById(String id) => '/applicants/$id';

  // Dependents endpoints
  static const String dependents = '/dependents';
  static String dependentById(String id) => '/dependents/$id';

  // Loans endpoints
  static const String loans = '/loans';
  static String loanById(String id) => '/loans/$id';
}
