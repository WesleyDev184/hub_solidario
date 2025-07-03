import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_rotary/app/auth/data/impl_auth_repository.dart';
import 'package:project_rotary/app/auth/presentation/pages/forgot_password_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/signup_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/singin_page.dart';
import 'package:project_rotary/app/pdt/layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      home: const AuthWrapper(), // Usar AuthWrapper em vez de rota fixa
      routes: {
        '/signin': (context) => SingInPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/layout': (context) => Layout(),
      },
    );
  }
}

/// Widget que verifica se há uma sessão salva ao iniciar o app
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final ImplAuthRepository _authRepository = ImplAuthRepository();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Verifica se o usuário já está logado
  Future<void> _checkAuthStatus() async {
    try {
      // Tenta restaurar a sessão salva
      final sessionResult = await _authRepository.restoreSession();

      sessionResult.fold(
        (isRestored) {
          setState(() {
            _isLoggedIn = isRestored;
            _isLoading = false;
          });
        },
        (error) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando sessão...'),
            ],
          ),
        ),
      );
    }

    // Se está logado, vai para o layout principal
    if (_isLoggedIn) {
      return Layout();
    }

    // Se não está logado, vai para a tela de login
    return SingInPage();
  }

  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
