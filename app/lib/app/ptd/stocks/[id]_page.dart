import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/routes.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, a1, a2) => const StockPage(),
    transitionsBuilder: (_, a1, a2, child) {
      return FadeTransition(opacity: a1, child: child);
    },
  );
}

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Routefly.listenable,
      builder: (context, snapshot) {
        final id = Routefly.query['id'];
        return Scaffold(
          appBar: AppBarCustom(
            title: 'Produto $id',
            path: routePaths.ptd.stocks.path,
          ),
          body: Center(child: Text('Detalhes do produto $id')),
        );
      },
    );
  }
}
