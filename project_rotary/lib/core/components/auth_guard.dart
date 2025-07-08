import 'package:flutter/material.dart';
import 'package:project_rotary/core/api/auth/auth_service.dart';

/// Widget que protege rotas autenticadas
/// Redireciona para login se o usuário não estiver autenticado
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectTo = '/signin',
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = AuthService.instance;

      if (authController == null || !authController.isAuthenticated) {
        // Usuário não está logado, redireciona para login
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(widget.redirectTo!, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = AuthService.instance;

    // Se não há controller ou usuário não está autenticado, mostra loading
    if (authController == null || !authController.isAuthenticated) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade400, Colors.blue.shade800],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 24),
                Text(
                  'Verificando autenticação...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Usuário está autenticado, mostra o conteúdo
    return widget.child;
  }
}
