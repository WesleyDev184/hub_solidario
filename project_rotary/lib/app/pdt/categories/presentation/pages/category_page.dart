import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/presentation/controller/items_controller.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/add_item_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/create_loan_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/delete_category_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/pages/edit_category_page.dart';
import 'package:project_rotary/app/pdt/categories/presentation/widgets/action_menu_category.dart';
import 'package:project_rotary/app/pdt/categories/presentation/widgets/category_items_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final int available;
  final int inMaintenance;
  final int inUse;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.available,
    required this.inMaintenance,
    required this.inUse,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final ItemsController _itemsController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _itemsController = ItemsController();
    _initializeData();
  }

  @override
  void dispose() {
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!_isInitialized) {
      await _itemsController.loadAllItems();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _refreshItems() async {
    await _itemsController.loadAllItems();
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuCategory(
          onCreatePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AddItemPage(
                      categoryId: widget.categoryId,
                      categoryTitle: widget.categoryTitle,
                    ),
              ),
            ).then((_) => _refreshItems()); // Recarrega após adicionar item
          },
          onEditPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EditCategoryPage(
                      categoryId: widget.categoryId,
                      currentTitle: widget.categoryTitle,
                      currentAvailable: widget.available,
                      currentInMaintenance: widget.inMaintenance,
                      currentInUse: widget.inUse,
                    ),
              ),
            );
          },
          onDeletePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DeleteCategoryPage(
                      categoryId: widget.categoryId,
                      categoryTitle: widget.categoryTitle,
                    ),
              ),
            );
          },
          onBorrowPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => CreateLoanPage(
                      categoryId: widget.categoryId,
                      categoryTitle: widget.categoryTitle,
                    ),
              ),
            ).then((_) => _refreshItems()); // Recarrega após criar empréstimo
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarCustom(title: widget.categoryTitle),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260.0,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: CustomColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.asset(
                    'assets/images/cr.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.69,
            minChildSize: 0.68,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: CustomColors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColors.textPrimary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListenableBuilder(
                  listenable: _itemsController,
                  builder: (context, child) {
                    if (_itemsController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_itemsController.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.x,
                              size: 64,
                              color: CustomColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar itens',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CustomColors.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _itemsController.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CustomColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshItems,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // espaço para o botão
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              widget.categoryTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.warning.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _itemsController.borrowedItems.toString(),
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.check,
                                    color: CustomColors.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _itemsController.availableItems.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Disponíveis',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.wrench,
                                    color: CustomColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _itemsController.maintenanceItems
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Em manutenção',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: CustomColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Lista de itens da API
                        if (_itemsController.items.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  LucideIcons.package,
                                  size: 64,
                                  color: CustomColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum item encontrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Adicione itens a esta categoria',
                                  style: TextStyle(
                                    color: CustomColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children:
                                _itemsController.items
                                    .map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12.0,
                                        ),
                                        child: CategoryItemsCard(
                                          id: item.id,
                                          serialCode:
                                              item.serialCode.toString(),
                                          status: item.status,
                                          createdAt: item.createdAt,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActionsMenu(context),
        backgroundColor: CustomColors.primary,
        child: const Icon(LucideIcons.menu, color: Colors.white),
      ),
    );
  }
}
