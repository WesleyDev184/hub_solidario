import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:app/core/notifications/firebase_messaging_service.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController =
        Get.find<AuthController>(); // Obtém a instância do AuthController
    _router = createGoRouter(
      _authController,
    ); // Passa o AuthController para o roteador

    // Opcional, mas recomendado: Reconstruir o GoRouter quando o estado de autenticação muda.
    // Isso garante que a função `redirect` seja reavaliada.
    _authController.stateRx.listen((_) {
      _router.refresh();
    });

    // Inicialização do FirebaseMessagingService será feita no primeiro build
  }

  @override
  void dispose() {
    // Se você tiver um listener específico, pode removê-lo aqui
    // _authController.stateRx.removeListener(() => _router.refresh()); // Isso não é necessário com listen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Injeta o contexto e inicializa o FirebaseMessagingService no primeiro build
    final fcmService = Get.find<FirebaseMessagingService>();
    if (fcmService.context == null) {
      fcmService.setContext(context);
      fcmService.initialize();
    }

    return GetMaterialApp.router(
      theme: appTheme,
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // ...outros delegates se necessário...
      ],
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
