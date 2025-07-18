import 'package:app/app.dart';
import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routefly/routefly.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stocksController = Get.find<StocksController>();
    return Scaffold(
      appBar: AppBarCustom(title: 'Produtos', initialRoute: true),
      body: Obx(() {
        final stocks = stocksController.allStocks;
        if (stocksController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (stocks.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }
        return ListView.builder(
          itemCount: stocks.length,
          itemBuilder: (context, index) {
            final stock = stocks[index];
            return ListTile(
              title: Text(stock.title.toString()),
              subtitle: Text(stock.id),
              onTap: () {
                Routefly.push(
                  routePaths.products.$id.changes({'id': stock.id}),
                );
              },
            );
          },
        );
      }),
    );
  }
}
