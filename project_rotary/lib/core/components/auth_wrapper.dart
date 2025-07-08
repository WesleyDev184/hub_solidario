import 'package:flutter/material.dart';
import 'package:project_rotary/app/auth/di/auth_dependency_factory.dart';
import 'package:project_rotary/app/auth/pages/singin_page.dart';

/// Widget que monitora o estado de autenticação e redireciona automaticamente
/// para a tela de login quando o usuário é deslogado por questão de segurança
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final authController = AuthDependencyFactory.instance.authController;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = authController.isAuthenticated;

    // Escuta mudanças no estado de autenticação
    authController.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged() {
    final isCurrentlyAuthenticated = authController.isAuthenticated;

    // Se o usuário estava autenticado mas agora não está mais,
    // e há uma mensagem de erro relacionada à sessão expirada,
    // redireciona para a tela de login
    if (_wasAuthenticated && !isCurrentlyAuthenticated) {
      if (authController.error != null &&
          authController.error!.contains('sessão expirou')) {
        _redirectToLogin();
      }
    }

    _wasAuthenticated = isCurrentlyAuthenticated;
  }

  void _redirectToLogin() {
    if (mounted) {
      // Mostra uma mensagem informando sobre o logout automático
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.error ??
                'Sua sessão expirou. Por favor, faça login novamente.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );

      // Redireciona para a tela de login removendo todo o histórico
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SingInPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
