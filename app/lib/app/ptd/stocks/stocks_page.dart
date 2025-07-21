import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class StocksPage extends StatelessWidget {
  const StocksPage({super.key});

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
                context.go('/ptd/stocks/${stock.id}');
              },
            );
          },
        );
      }),
    );
  }
}
