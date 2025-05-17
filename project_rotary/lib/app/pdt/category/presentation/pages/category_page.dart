import 'package:flutter/material.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';

class CategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryPage({
    Key? key,
    required this.categoryId,
    required this.categoryTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: categoryTitle),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Detalhes da categoria: $categoryTitle (ID: $categoryId)',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
