import 'package:app/app.dart';
import 'package:app/core/api/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(412, 915), // Defina a largura e altura desejadas
    center: true, // Centraliza a janela na tela
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  usePathUrlStrategy();

  final apiClient = ApiClient();

  await AuthService.initialize(apiClient);
  await OrthopedicBanksService.initialize(apiClient);
  await StocksService.initialize(apiClient);
  await LoansService.initialize(apiClient);
  await ApplicantsService.initialize(apiClient);

  runApp(const App());
}
