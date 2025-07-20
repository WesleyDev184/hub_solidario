import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:routefly/routefly.dart';

Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, a1, a2) => const StocksPage(),
    transitionsBuilder: (_, a1, a2, child) {
      return FadeTransition(opacity: a1, child: child);
    },
  );
}

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
                Routefly.pushNavigate(
                  routePaths.ptd.stocks.$id.changes({'id': stock.id}),
                );
              },
            );
          },
        );
      }),
    );
  }
}
