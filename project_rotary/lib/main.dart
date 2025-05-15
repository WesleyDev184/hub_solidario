import 'package:flutter/material.dart';
import 'package:project_rotary/app/applicants/presentation/pages/applicants_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/signup_page.dart';
import 'package:project_rotary/app/auth/presentation/pages/singin_page.dart';
import 'package:project_rotary/app/categories/presentation/pages/categories_page.dart';
import 'package:project_rotary/app/info/presentation/pages/info_page.dart';
import 'package:project_rotary/app/loans/presentation/pages/loans_page.dart';

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
        '/categories': (context) => CategoriesPage(),
        '/info': (context) => const InfoPage(),
        '/loans': (context) => const LoansPage(),
        '/applicants': (context) => const ApplicantsPage(),
      },
    );
  }
}
