/// Configurações da API Rotary
class ApiConfig {
  static const String baseUrl = 'https://api.core.hubsolidario.com';
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
  static String usersByHub(String hubId) => '/users/hub/$hubId';

  // Hubs endpoints
  static const String hubs = '/hubs';
  static String hubById(String id) => '/hubs/$id';

  // Stocks endpoints
  static const String stocks = '/stocks';
  static String stockById(String id) => '/stocks/$id';
  static String stocksByHub(String hubId) => '/stocks/hub/$hubId';

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

  // Documents endpoints
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';
  static String documentsByApplicant(String applicantId) =>
      '/documents/applicant/$applicantId';
  static String documentsByDependent(String dependentId) =>
      '/documents/dependent/$dependentId';
}
