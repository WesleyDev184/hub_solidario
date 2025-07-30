import 'package:app/app.dart';
import 'package:app/core/api/api.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  runApp(const Center(child: CircularProgressIndicator()));
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await windowManager.ensureInitialized();

  // WindowOptions windowOptions = WindowOptions(
  //   size: Size(412, 915), // Defina a largura e altura desejadas
  //   center: true, // Centraliza a janela na tela
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.normal,
  // );

  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  final apiClient = ApiClient();

  await AuthService.initialize(apiClient);

  await Future.wait([
    HubsService.initialize(apiClient),
    StocksService.initialize(apiClient),
    LoansService.initialize(apiClient),
    ApplicantsService.initialize(apiClient),
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

  // Envia notificação de boas-vindas usando o serviço global
  notificationService.showLocalNotification(
    CustomNotification(
      id: 1,
      title: 'Bem-vindo!',
      body: 'Seja bem-vindo ao aplicativo Rotary!',
      payload: '',
    ),
  );

  runApp(const App());
}
