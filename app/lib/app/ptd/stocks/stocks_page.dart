import 'package:app/app/ptd/stocks/widgets/stock_card.dart';
import 'package:app/core/api/stocks/controllers/stocks_controller.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StocksPage extends StatefulWidget {
  const StocksPage({super.key});

  @override
  State<StocksPage> createState() => _StocksPageState();
}

class _StocksPageState extends State<StocksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      tooltip: 'Ações',
      child: const Icon(LucideIcons.plus),
      onPressed: () {
        context.go(RoutePaths.ptd.addStock);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stocksController = Get.find<StocksController>();
    return Scaffold(
      appBar: AppBarCustom(title: 'Produtos', initialRoute: true),
      floatingActionButton: _buildFloatingActionButton(),
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final stocks = stocksController.allStocks;
              if (stocksController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final filteredStocks = _searchText.isEmpty
                  ? stocks
                  : stocks
                        .where(
                          (stock) => stock.title
                              .toString()
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()),
                        )
                        .toList();
              if (filteredStocks.isEmpty) {
                return const Center(child: Text('Nenhum produto encontrado.'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: filteredStocks.map<Widget>((stock) {
                    return SizedBox(
                      width: 184,
                      height: 250, // ajuste conforme necessário
                      child: GestureDetector(
                        onTap: () {
                          context.go(RoutePaths.ptd.stockId(stock.id));
                        },
                        child: StockCard(
                          id: stock.id,
                          imageUrl: stock.imageUrl ?? '',
                          title: stock.title.toString(),
                          available: stock.availableQtd,
                          inUse: stock.borrowedQtd,
                          inMaintenance: stock.maintenanceQtd,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
