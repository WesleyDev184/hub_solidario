import 'package:flutter/material.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => SingInPage(),
        '/signup': (context) => SignUpPage(),
        '/layout': (context) => Layout(),
      },
    );
  }
}
