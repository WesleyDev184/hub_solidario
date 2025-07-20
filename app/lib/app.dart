import 'package:app/core/middleware/middlewares.dart';
import 'package:app/core/widgets/auth_builder.dart';
import 'package:app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routefly/routefly.dart';

// @Main('lib/app')
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: (context, child) {
        return AuthBuilder(child: child!);
      },
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // ...outros delegates se necessário...
      ],
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: routePaths.path,
        middlewares: [Middlewares().checkUserPermissions],
      ),
    );
  }
}
