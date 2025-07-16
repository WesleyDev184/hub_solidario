import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import 'my_app.route.dart';

part 'my_app.g.dart';

@Main('lib/app')
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routefly.routerConfig(
        routes: routes, // GENERATED
      ),
    );
  }
}
