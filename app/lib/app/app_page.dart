import 'package:app/core/widgets/appbar_custom.dart';
import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.title = 'Rotary App'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: title, initialRoute: true),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
