import 'package:app/app.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Routefly.listenable,
      builder: (context, snapshot) {
        final id = Routefly.query['id'];
        return Scaffold(
          appBar: AppBarCustom(
            title: 'Produto $id',
            path: routePaths.products.path,
          ),
          body: Center(child: Text('Detalhes do produto $id')),
        );
      },
    );
  }
}
