import 'package:app/app.dart';
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Routefly.push(routePaths.path),
        ),
        title: Text('Produtos'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name'] as String),
            onTap: () {
              Routefly.navigate(
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
