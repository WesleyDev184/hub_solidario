import 'package:get/get.dart';

import 'notifications_service.dart';

class NotificationsModule extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationService>(() => NotificationService());
  }
}
