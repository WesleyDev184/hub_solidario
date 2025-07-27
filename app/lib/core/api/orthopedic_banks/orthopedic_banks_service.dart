import 'package:app/core/api/api_client.dart';
import 'package:get/get.dart';

import 'orthopedic_banks.dart';

class OrthopedicBanksService {
  static OrthopedicBanksService? _instance;

  late final OrthopedicBanksController orthopedicBanksController;
  final ApiClient apiClient;

  OrthopedicBanksService._internal(this.apiClient);

  static OrthopedicBanksService get instance {
    if (_instance == null) {
      throw Exception(
        'OrthopedicBanksService not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = OrthopedicBanksService._internal(apiClient);

    final cacheService = await OrthopedicBanksCacheService.create();
    final repository = OrthopedicBanksRepository(
      apiClient: apiClient,
      cacheService: cacheService,
    );

    service.orthopedicBanksController = OrthopedicBanksController(
      repository,
      cacheService,
    );

    Get.put<OrthopedicBanksController>(
      service.orthopedicBanksController,
      permanent: true,
    );

    _instance = service;
  }
}
