import 'package:app/core/middleware/middlewares.dart';
import 'package:app/core/widgets/auth_builder.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import 'app.route.dart';

part 'app.g.dart';

@Main('lib/app')
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
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: routePaths.path,
        middlewares: [Middlewares().checkUserPermissions],
      ),
    );
  }
}
