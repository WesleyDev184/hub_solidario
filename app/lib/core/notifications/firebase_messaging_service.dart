import 'package:app/core/notifications/notifications_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class FirebaseMessagingService extends GetxController {
  final NotificationService _notificationService;
  BuildContext? context;

  FirebaseMessagingService(this._notificationService, [this.context]);

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          badge: true,
          sound: true,
          alert: true,
        );
    getDeviceFirebaseToken();
    _onMessage();
    _onMessageOpenedApp();
  }

  Future<String> getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('=======================================');
    debugPrint('TOKEN: $token');
    debugPrint('=======================================');
    return token!;
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showLocalNotification(
          CustomNotification(
            id: android.hashCode,
            title: notification.title!,
            body: notification.body!,
            payload: message.data['route'] ?? '',
          ),
        );
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String route = message.data['route'] ?? '';
    if (route.isNotEmpty && context != null) {
      GoRouter.of(context!).go(route);
    }
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }
}
