import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  final String id;
  const StockPage({super.key, required this.id});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    return Scaffold(
      appBar: AppBarCustom(title: 'Produto $id', path: RoutePaths.ptd.stocks),
      body: Center(child: Text('Detalhes do produto $id')),
    );
  }
}
