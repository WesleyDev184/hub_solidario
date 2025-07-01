import 'package:flutter/material.dart';
import 'package:project_rotary/app/pdt/layout.dart';
import 'package:project_rotary/core/components/auth_wrapper.dart';

/// Exemplo de como usar o AuthWrapper no aplicativo
///
/// Para usar a funcionalidade de logout automático em caso de erro 401,
/// você deve envolver suas telas autenticadas com o AuthWrapper:
///
/// ```dart
/// // No main.dart ou onde você define as rotas
/// MaterialApp(
///   home: AuthWrapper(
///     child: Layout(), // Sua tela principal autenticada
///   ),
///   // ... outras configurações
/// )
/// ```
///
/// O AuthWrapper irá:
/// 1. Monitorar o estado de autenticação
/// 2. Detectar quando o usuário é deslogado automaticamente por erro 401
/// 3. Mostrar uma mensagem de notificação
/// 4. Redirecionar automaticamente para a tela de login
class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Layout(), // Sua aplicação principal
    );
  }
}

/// Exemplo de como configurar no MaterialApp
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotary App',
      home: const AuthenticatedApp(),
      routes: {
        '/layout': (context) => const AuthWrapper(child: Layout()),
        // outras rotas...
      },
    );
  }
}
