import 'package:app/core/api/api_client.dart';
import 'package:get/get.dart';

import 'hubs.dart';

class HubsService {
  static HubsService? _instance;

  late final HubsController hubsController;
  final ApiClient apiClient;

  HubsService._internal(this.apiClient);

  static HubsService get instance {
    if (_instance == null) {
      throw Exception('HubsService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize(ApiClient apiClient) async {
    final service = HubsService._internal(apiClient);

    final cacheService = await HubsCacheService.create();
    final repository = HubsRepository(
      apiClient: apiClient,
      cacheService: cacheService,
    );

    service.hubsController = HubsController(repository, cacheService);

    Get.put<HubsController>(service.hubsController, permanent: true);

    _instance = service;
  }
}
