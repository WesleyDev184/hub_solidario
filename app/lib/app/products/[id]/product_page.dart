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
          appBar: AppBar(title: Text('Produto $id')),
          body: Center(child: Text('Detalhes do produto $id')),
        );
      },
    );
  }
}
