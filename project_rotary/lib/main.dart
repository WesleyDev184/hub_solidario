import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_rotary/app/auth/pages/forgot_password_page.dart';
import 'package:project_rotary/app/auth/pages/signup_page.dart';
import 'package:project_rotary/app/auth/pages/singin_page.dart';
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
      home: SingInPage(), // Ir direto para a página de login
      routes: {
        '/signin': (context) => SingInPage(),
        '/signup': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/layout': (context) => Layout(),
      },
    );
  }
}
