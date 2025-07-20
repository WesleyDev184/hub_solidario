import 'dart:async';

import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class Middlewares {
  FutureOr<RouteInformation> checkUserPermissions(RouteInformation routeInfo) {
    final authController = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        'Mid: checkUserPermissions called with state: ${routeInfo.uri.path}',
      );
      authController.checkUserPermissions(routeInfo.uri.path, true);
    });

    return routeInfo;
  }
}
