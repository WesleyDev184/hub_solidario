import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, this.title = 'HS App'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: CircularProgressIndicator()));
  }
}
