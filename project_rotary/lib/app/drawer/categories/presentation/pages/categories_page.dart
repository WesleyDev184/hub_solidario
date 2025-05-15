import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/drawer/categories/presentation/widgets/category_card.dart';
import 'package:project_rotary/core/components/input_field.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> categoryData = [
    {
      "id": "1",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Cadeira de Rodas",
      "available": 10,
      "inUse": 3,
      "inMaintenance": 2,
    },
    {
      "id": "2",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Muletas",
      "available": 5,
      "inUse": 7,
      "inMaintenance": 1,
    },
    {
      "id": "3",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Andador",
      "available": 8,
      "inUse": 2,
      "inMaintenance": 0,
    },
    {
      "id": "4",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Cadeira de banho",
      "available": 12,
      "inUse": 4,
      "inMaintenance": 3,
    },
    {
      "id": "5",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Botas ortopédicas",
      "available": 7,
      "inUse": 5,
      "inMaintenance": 2,
    },
  ];

  List<Map<String, dynamic>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = List.from(categoryData);
    searchController.addListener(filterCategories);
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCategories =
          query.isEmpty
              ? List.from(categoryData)
              : categoryData.where((category) {
                final title = category["title"].toString().toLowerCase();
                return title.contains(query);
              }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterCategories);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removemos os widgets de estrutura para permitir o uso em IndexedStack
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          InputField(
            controller: searchController,
            hint: "Buscar",
            icon: LucideIcons.search,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimationLimiter(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 2,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: CategoryCard(
                          id: category["id"],
                          imageUrl: category["imageUrl"],
                          title: category["title"],
                          available: category["available"],
                          inUse: category["inUse"],
                          inMaintenance: category["inMaintenance"],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
