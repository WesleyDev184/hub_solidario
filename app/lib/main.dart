import 'package:app/app.dart';
import 'package:app/core/api/api.dart';
import 'package:app/core/notifications/firebase_messaging_service.dart';
import 'package:app/core/notifications/notifications_service.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  // Exibe loading enquanto inicializa
  runApp(const Center(child: CircularProgressIndicator()));
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final apiClient = ApiClient();

  await AuthService.initialize(apiClient);

  await Future.wait([
    HubsService.initialize(apiClient),
    StocksService.initialize(apiClient),
    LoansService.initialize(apiClient),
    ApplicantsService.initialize(apiClient),
    DocumentsService.initialize(apiClient),
  ]);

  // Registra NotificationService globalmente com GetX
  Get.put<NotificationService>(NotificationService(), permanent: true);
  // Solicita permissão de notificação se necessário
  final notificationService = Get.find<NotificationService>();
  await notificationService.ensureNotificationPermission();

  // Registra FirebaseMessagingService globalmente sem contexto
  Get.put<FirebaseMessagingService>(
    FirebaseMessagingService(notificationService, null),
    permanent: true,
  );

  runApp(const App());
}
