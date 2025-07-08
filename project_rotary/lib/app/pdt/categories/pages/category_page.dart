import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/pages/add_item_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/create_loan_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/delete_category_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/edit_category_page.dart';
import 'package:project_rotary/app/pdt/categories/widgets/action_menu_category.dart';
import 'package:project_rotary/app/pdt/categories/widgets/category_items_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final int available;
  final int inMaintenance;
  final int inUse;
  final String? imageUrl;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.available,
    required this.inMaintenance,
    required this.inUse,
    this.imageUrl,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Dados mockados
  int availableItems = 15;
  int borrowedItems = 5;
  int inMaintenanceItems = 3;

  List<Map<String, dynamic>> mockItems = [
    {
      'id': '1',
      'serialCode': '001',
      'status': 'available',
      'categoryId': 'category_1',
    },
    {
      'id': '2',
      'serialCode': '002',
      'status': 'borrowed',
      'categoryId': 'category_1',
    },
    {
      'id': '3',
      'serialCode': '003',
      'status': 'maintenance',
      'categoryId': 'category_1',
    },
    {
      'id': '4',
      'serialCode': '004',
      'status': 'available',
      'categoryId': 'category_1',
    },
    {
      'id': '5',
      'serialCode': '005',
      'status': 'available',
      'categoryId': 'category_1',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (!_isInitialized) {
      setState(() {
        _isLoading = true;
      });

      // Simula carregamento
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _refreshItems() async {
    setState(() {
      _isLoading = true;
    });

    // Simula recarregamento
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildImage() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Verifica se é uma URL de rede (http/https)
      if (widget.imageUrl!.startsWith('http://') ||
          widget.imageUrl!.startsWith('https://')) {
        return Image.network(
          widget.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Se falhar ao carregar a imagem de rede, usa a imagem padrão
            return Image.asset('assets/images/cr.jpg', fit: BoxFit.cover);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: CustomColors.white,
              child: Center(
                child: CircularProgressIndicator(
                  color: CustomColors.primary,
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              ),
            );
          },
        );
      } else {
        // Se não é uma URL de rede, trata como asset
        return Image.asset(
          widget.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Se falhar ao carregar o asset, usa a imagem padrão
            return Image.asset('assets/images/cr.jpg', fit: BoxFit.cover);
          },
        );
      }
    } else {
      // Se imageUrl é null ou vazio, usa a imagem padrão
      return Image.asset('assets/images/cr.jpg', fit: BoxFit.cover);
    }
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActionMenuCategory(
          onCreatePressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder:
                    (context) => AddItemPage(
                      categoryId: widget.categoryId,
                      categoryTitle: widget.categoryTitle,
                    ),
              ),
            );

            if (result == true) {
              // Recarrega os itens após adicionar um novo item
              _refreshItems();
            }
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
            Navigator.pop(context);
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: widget.categoryTitle),
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 260.0,
              floating: false,
              pinned: false,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(background: _buildImage()),
            ),
          ];
        },
        body: DraggableScrollableSheet(
          initialChildSize: 0.99,
          minChildSize: 0.99,
          maxChildSize: 0.99,
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
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
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
                              _errorMessage!,
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
                      )
                      : ListView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
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
                                  borrowedItems.toString(),
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
                                      availableItems.toString(),
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
                                      inMaintenanceItems.toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: CustomColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Manutenção',
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
                          if (mockItems.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.package,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Nenhum item encontrado',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Adicione o primeiro item desta categoria',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Column(
                              children:
                                  mockItems
                                      .map(
                                        (item) => CategoryItemsCard(
                                          id: item['id'] as String,
                                          serialCode:
                                              item['serialCode'].toString(),
                                          status: item['status'] as String,
                                          createdAt: DateTime.now(),
                                        ),
                                      )
                                      .toList(),
                            ),
                        ],
                      ),
            );
          },
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
