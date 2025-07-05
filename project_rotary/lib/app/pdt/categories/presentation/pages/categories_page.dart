import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/auth/di/auth_dependency_factory.dart';
import 'package:project_rotary/app/pdt/categories/di/category_dependency_factory.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/category_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/new_category_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/widgets/action_menu_categories.dart';
import 'package:project_rotary/app/pdt/categories/presentation/widgets/category_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/input_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController searchController = TextEditingController();

  // Controllers
  late final _authController = AuthDependencyFactory.instance.authController;
  late final _categoryController =
      CategoryDependencyFactory.instance.categoryController;

  List<Map<String, dynamic>> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterCategories);
    _loadCategories();
  }

  /// Carrega categorias do banco ortopédico do usuário logado
  Future<void> _loadCategories() async {
    try {
      // Primeiro obtém o usuário atual
      final currentUserResult = await _authController.getCurrentUser();

      if (currentUserResult.isSuccess()) {
        final user = currentUserResult.getOrNull();
        if (user != null && user.orthopedicBank != null) {
          // Busca categorias pelo banco ortopédico do usuário
          await _categoryController.getCategoriesByOrthopedicBank(
            orthopedicBankId: user.orthopedicBank!.id,
          );
        } else {
          debugPrint('Usuário não possui banco ortopédico associado');
        }
      } else {
        debugPrint(
          'Erro ao obter usuário atual: ${currentUserResult.exceptionOrNull()}',
        );
      }
    } catch (e) {
      debugPrint('Erro ao carregar categorias: $e');
    }
  }

  void filterCategories() {
    final query = searchController.text.toLowerCase();
    setState(() {
      final allCategories = _categoryController.categories;
      filteredCategories =
          query.isEmpty
              ? allCategories
                  .map(
                    (category) => {
                      "id": category.id,
                      "imageUrl": category.imageUrl ?? "assets/images/cr.jpg",
                      "title": category.title,
                      "availableQtd": category.availableQtd ?? 0,
                      "borrowedQtd": category.borrowedQtd ?? 0,
                      "maintenanceQtd": category.maintenanceQtd ?? 0,
                    },
                  )
                  .toList()
              : allCategories
                  .where(
                    (category) => category.title.toLowerCase().contains(query),
                  )
                  .map(
                    (category) => {
                      "id": category.id,
                      "imageUrl": category.imageUrl ?? "assets/images/cr.jpg",
                      "title": category.title,
                      "availableQtd": category.availableQtd ?? 0,
                      "borrowedQtd": category.borrowedQtd ?? 0,
                      "maintenanceQtd": category.maintenanceQtd ?? 0,
                    },
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
      body: ListenableBuilder(
        listenable: _categoryController,
        builder: (context, child) {
          // Atualizar filteredCategories quando as categorias mudarem
          WidgetsBinding.instance.addPostFrameCallback((_) {
            filterCategories();
          });

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
                if (_categoryController.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: CustomColors.primary,
                      ),
                    ),
                  )
                else if (_categoryController.errorMessage != null)
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
                            _categoryController.errorMessage!,
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
                                              available:
                                                  category['availableQtd'],
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: Colors.white),
      ),
    );
  }
}
