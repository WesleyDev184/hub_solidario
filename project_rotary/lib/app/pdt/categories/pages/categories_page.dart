import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/pages/category_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/new_category_page.dart';
import 'package:project_rotary/app/pdt/categories/widgets/action_menu_categories.dart';
import 'package:project_rotary/app/pdt/categories/widgets/category_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoriesPage extends StatefulWidget {
  final Function(VoidCallback)? onRefreshCallback;

  const CategoriesPage({super.key, this.onRefreshCallback});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Dados mockados para categorias
  final List<Map<String, dynamic>> _allCategories = [
    {
      "id": "1",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Cadeiras de Rodas",
      "availableQtd": 15,
      "borrowedQtd": 5,
      "maintenanceQtd": 2,
    },
    {
      "id": "2",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Muletas",
      "availableQtd": 25,
      "borrowedQtd": 8,
      "maintenanceQtd": 1,
    },
    {
      "id": "3",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Andadores",
      "availableQtd": 12,
      "borrowedQtd": 3,
      "maintenanceQtd": 0,
    },
    {
      "id": "4",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Órteses",
      "availableQtd": 30,
      "borrowedQtd": 12,
      "maintenanceQtd": 3,
    },
    {
      "id": "5",
      "imageUrl": "assets/images/cr.jpg",
      "title": "Próteses",
      "availableQtd": 8,
      "borrowedQtd": 2,
      "maintenanceQtd": 1,
    },
  ];

  List<Map<String, dynamic>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterCategories);
    _loadCategories();

    // Registra o callback para recarregar a página
    widget.onRefreshCallback?.call(_refreshPage);
  }

  void _refreshPage() {
    _loadCategories();
  }

  /// Carrega categorias (simulação com dados mockados)
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    // Simula carregamento
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      filteredCategories = List.from(_allCategories);
    });
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCategories =
          query.isEmpty
              ? List.from(_allCategories)
              : _allCategories
                  .where(
                    (category) =>
                        category["title"].toLowerCase().contains(query),
                  )
                  .toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(filterCategories);
    searchController.dispose();
    super.dispose();
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuCategories(
          title: 'Ações',
          onCreatePressed: () async {
            // Navegar para nova categoria e aguardar resultado
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (context) => const NewCategoryPage()),
            );

            // Se retornou true, significa que uma categoria foi criada
            if (result == true) {
              _loadCategories(); // Recarregar a lista de categorias
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: "Categorias"),
      backgroundColor: Colors.transparent,
      body: Padding(
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
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: CustomColors.primary),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCategories,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: AnimationLimiter(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CategoryPage(
                                          categoryId: category["id"],
                                          categoryTitle: category["title"],
                                          available: category['availableQtd'],
                                          inMaintenance:
                                              category['maintenanceQtd'],
                                          inUse: category['borrowedQtd'],
                                          imageUrl: category["imageUrl"],
                                        ),
                                  ),
                                );
                              },
                              child: CategoryCard(
                                id: category["id"],
                                imageUrl: category["imageUrl"],
                                title: category["title"],
                                available: category["availableQtd"],
                                inUse: category["borrowedQtd"],
                                inMaintenance: category["maintenanceQtd"],
                              ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: Colors.white),
      ),
    );
  }
}
