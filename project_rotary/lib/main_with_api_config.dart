import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_rotary/app/auth/presentation/pages/forgot_password_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/signup_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/singin_page.dart';
import 'package:project_rotary/app/pdt/layout.dart';

void main() {
  // Inicialização da aplicação
  WidgetsFlutterBinding.ensureInitialized();

  // Configuração da API (descomente e configure conforme necessário)
  // AuthDependencyFactory.instance.apiClient.setApiKey('sua-api-key-aqui');

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
      initialRoute: '/',
      routes: {
        '/': (context) => SingInPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/layout': (context) => Layout(),
      },
    );
  }
}
