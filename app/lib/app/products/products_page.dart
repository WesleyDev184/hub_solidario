import 'package:app/my_app.dart';
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
      appBar: AppBar(title: const Text('Produtos')),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name'] as String),
            onTap: () {
              Routefly.navigate(
                routePaths.products.$id.product.changes({
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
