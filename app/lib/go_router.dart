import 'package:app/core/api/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app/app_page.dart';
import 'app/auth/forgot_password_page.dart';
import 'app/auth/signin_page.dart';
import 'app/auth/signup_page.dart';
import 'app/ptd/info/info_page.dart';
import 'app/ptd/option2_page.dart';
import 'app/ptd/option3_page.dart';
import 'app/ptd/ptd_layout.dart';
import 'app/ptd/stocks/stock_page.dart';
import 'app/ptd/stocks/stocks_page.dart';

GoRouter createGoRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AppPage()),
      GoRoute(
        path: '/auth/signin',
        builder: (context, state) => const SigninPage(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/auth/forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/ptd',
        builder: (context, state) => const PtdLayout(),
        routes: [
          GoRoute(
            path: 'stocks',
            builder: (context, state) => const StocksPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    StockPage(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: 'info', builder: (context, state) => const InfoPage()),
          GoRoute(
            path: 'option2',
            builder: (context, state) => const Option2Page(),
          ),
          GoRoute(
            path: 'option3',
            builder: (context, state) => const Option3Page(),
          ),
        ],
      ),
    ],
    // --- Adicione a função de redirecionamento aqui ---
    redirect: (BuildContext context, GoRouterState state) async {
      final bool isLoggedIn = authController.isAuthenticated;
      final bool hasValidToken = await authController.cacheService
          .hasValidToken();
      final String currentPath = state.matchedLocation;
      debugPrint("Current path: $currentPath");

      final List<String> publicPaths = [
        '/auth/signin',
        '/auth/signup',
        '/auth/forgot_password',
      ];

      final bool goingToPublicPath = publicPaths.contains(currentPath);

      if (!isLoggedIn && !goingToPublicPath) {
        return '/auth/signin';
      }

      if (isLoggedIn && goingToPublicPath) {
        return '/ptd/stocks';
      }

      if (isLoggedIn && !hasValidToken) {
        await authController.logout();
        return '/auth/signin';
      }

      if (isLoggedIn && currentPath == '/') {
        return '/ptd/stocks';
      }

      return null;
    },
    // Opcional: Tratamento de erros para rotas não encontradas
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(child: Text('Página não encontrada: ${state.error}')),
    ),
  );
}

// Helpers para navegação por nome
class RoutePaths {
  static const String root = '/';
  static const auth = _AuthPaths();
  static const ptd = _PtdPaths();
}

class _AuthPaths {
  const _AuthPaths();
  String get signin => '/auth/signin';
  String get signup => '/auth/signup';
  String get forgotPassword => '/auth/forgot_password';
}

class _PtdPaths {
  const _PtdPaths();
  String get root => '/ptd';
  String get stocks => '/ptd/stocks';
  String stockId(String id) => '/ptd/stocks/$id';
  String get info => '/ptd/info';
  String get option2 => '/ptd/option2';
  String get option3 => '/ptd/option3';
}
