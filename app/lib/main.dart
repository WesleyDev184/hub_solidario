import 'package:app/app.dart';
import 'package:app/core/api/api.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Handler top-level para mensagens FCM em background/terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa NotificationService para exibir notificação local
  final notificationService = NotificationService();
  // Cria CustomNotification a partir da mensagem recebida
  final notification = CustomNotification(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // id único simples
    title: message.notification?.title ?? 'Nova mensagem',
    body: message.notification?.body ?? 'Você recebeu uma nova notificação.',
    payload: '',
    remoteMessage: message,
  );
  notificationService.showLocalNotification(notification);
}

void main() async {
  // Exibe loading enquanto inicializa
  runApp(const Center(child: CircularProgressIndicator()));
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Registra o handler para mensagens FCM em background/terminated
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  runApp(const App());
}
