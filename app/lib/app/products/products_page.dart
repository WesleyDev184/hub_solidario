import 'package:app/app.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'id': 1, 'name': 'Produto 1'},
      {'id': 2, 'name': 'Produto 2'},
      {'id': 3, 'name': 'Produto 3'},
    ];
    return Scaffold(
      appBar: AppBarCustom(title: 'Produtos', initialRoute: true),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name'] as String),
            onTap: () {
              Routefly.pushNavigate(
                routePaths.products.$id.changes({
                  'id': product['id'].toString(),
                }),
              );
            },
          );
        },
      ),
    );
  }
}
