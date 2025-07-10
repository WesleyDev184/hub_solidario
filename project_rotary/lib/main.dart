import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_rotary/app/auth/pages/forgot_password_page.dart';
import 'package:project_rotary/app/auth/pages/signup_page.dart';
import 'package:project_rotary/app/auth/pages/singin_page.dart';
import 'package:project_rotary/app/pdt/layout.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o ApiClient
  final apiClient = ApiClient();

  // Inicializa o serviço de autenticação
  try {
    await AuthService.initialize(apiClient: apiClient);
    debugPrint('AuthService inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar AuthService: $e');
    // Continue mesmo se houver erro no AuthService
  }

  // Inicializa o serviço de aplicantes
  try {
    await ApplicantsService.initialize(apiClient: apiClient);
    debugPrint('ApplicantsService inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar ApplicantsService: $e');
    // Continue mesmo se houver erro no ApplicantsService
  }

  // inicializa o serviço de categorias
  try {
    await StocksService.initialize(apiClient: apiClient);
    debugPrint('StockService inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar StockService: $e');
    // Continue mesmo se houver erro no CategoriesService
  }

  try {
    await ItemsService.initialize(apiClient: apiClient);
    debugPrint('ItemService inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar ItemService: $e');
    // Continue mesmo se houver erro no CategoriesService
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotary Project',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const AuthChecker(), // Verifica autenticação inicial
      routes: {
        '/signin': (context) => SingInPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/layout': (context) => AuthGuard(child: Layout()),
      },
    );
  }
}

/// Widget que verifica se o usuário está autenticado
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Aguarda até que o AuthService esteja completamente inicializado
      while (!AuthService.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (mounted) {
        final authController = AuthService.instance;

        setState(() {
          _isChecking = false;
        });

        // Usa addPostFrameCallback para adiar a navegação
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (authController != null && authController.isAuthenticated) {
              // Usuário já está logado, vai para o layout principal
              Navigator.pushReplacementNamed(context, '/layout');
            } else {
              // Usuário não está logado, vai para a tela de login
              Navigator.pushReplacementNamed(context, '/signin');
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Erro ao verificar autenticação: $e');
      if (mounted) {
        setState(() {
          _isChecking = false;
        });

        // Usa addPostFrameCallback para adiar a navegação
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/signin');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de loading enquanto verifica a autenticação
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 24),
              Text(
                _isChecking
                    ? 'Verificando autenticação...'
                    : 'Redirecionando...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
