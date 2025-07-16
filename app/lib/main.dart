import 'package:app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Deve ser chamado antes de runApp para garantir que o window_manager esteja pronto
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
  
  runApp(const MyApp());
}
