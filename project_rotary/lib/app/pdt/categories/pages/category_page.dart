import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/pages/add_item_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/create_loan_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/delete_category_page.dart';
import 'package:project_rotary/app/pdt/categories/pages/edit_category_page.dart';
import 'package:project_rotary/app/pdt/categories/widgets/action_menu_category.dart';
import 'package:project_rotary/app/pdt/categories/widgets/category_items_card.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/select_field.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/status_utils.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;
  final Stock stock;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.stock,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool _isLoading = false;
  String? _errorMessage;
  Stock? _stock;

  // Listagem dos items
  List<Item> _items = [];
  List<Item> _filteredItems = [];

  // Filtro de status
  ItemStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    // Inicializa o stock
    _stock = widget.stock;
    // Usa addPostFrameCallback para adiar a chamada até depois do build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    // Limpa os dados e estados ao sair da página
    _items.clear();
    _filteredItems.clear();
    _selectedStatusFilter = null;
    _isLoading = false;
    _errorMessage = null;
    _stock = null;
    super.dispose();
  }

  Future<void> _initializeData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carrega os itens da categoria
      final response = await ItemsService.getItemsByStock(
        widget.categoryId,
        forceRefresh: forceRefresh,
      );

      response.fold(
        (data) {
          setState(() {
            _items = data;
            _filteredItems = _applyStatusFilter(data);
            _isLoading = false;
          });
        },
        (error) {
          setState(() {
            _errorMessage = "Erro ao carregar itens: $error";
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar itens: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      height: 260.0,
      decoration: BoxDecoration(color: CustomColors.white),
      child: ClipRect(child: _buildImageContent()),
    );
  }

  Widget _buildImageContent() {
    // Widget padrão para fallback
    Widget defaultImage = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: CustomColors.primary.withOpacity(0.1),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CustomColors.primary.withOpacity(0.3),
            CustomColors.primary.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.image,
            size: 64,
            color: CustomColors.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          Text(
            _stock?.title ?? 'Categoria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    // Se não tem URL de imagem, retorna o widget padrão
    if (_stock?.imageUrl == null || _stock?.imageUrl?.isEmpty == true) {
      return defaultImage;
    }

    // Se é uma URL de rede
    if (_stock!.imageUrl!.startsWith('http://') ||
        _stock!.imageUrl!.startsWith('https://')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: CustomColors.primary.withOpacity(0.1)),
        child: Image.network(
          _stock!.imageUrl!,
          fit: BoxFit.contain, // Mantém a proporção sem distorção
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Erro ao carregar imagem de rede: $error');
            return defaultImage;
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: CustomColors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: CustomColors.primary,
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando imagem...',
                      style: TextStyle(
                        color: CustomColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Se é um asset local
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: CustomColors.primary.withOpacity(0.1)),
        child: Image.asset(
          _stock!.imageUrl!,
          fit: BoxFit.contain, // Mantém a proporção sem distorção
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Erro ao carregar asset de imagem: $error');
            return defaultImage;
          },
        ),
      );
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
                      categoryTitle: _stock?.title ?? 'Categoria',
                    ),
              ),
            );

            if (result == true) {
              // Recarrega os itens após adicionar um novo item
              _initializeData();
            } else {
              // Se não foi adicionado, recarrega os itens para garantir que a lista esteja atualizada
              _initializeData(forceRefresh: true);
            }
          },
          onEditPressed: () async {
            final res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => EditCategoryPage(
                      categoryId: widget.categoryId,
                      currentTitle: _stock?.title ?? 'Categoria',
                      currentAvailable: _stock?.availableQtd ?? 0,
                      currentInMaintenance: _stock?.maintenanceQtd ?? 0,
                      currentInUse: _stock?.borrowedQtd ?? 0,
                    ),
              ),
            );

            // Se o usuário editou a categoria, atualiza o estado
            if (res != null && res is Stock) {
              setState(() {
                _stock = res;
              });
            } else {
              // Se não foi editado, recarrega os itens para garantir que a lista esteja atualizada
              _initializeData(forceRefresh: true);
            }
          },
          onDeletePressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => DeleteCategoryPage(
                      categoryId: widget.categoryId,
                      categoryTitle: _stock?.title ?? 'Categoria',
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
                      categoryTitle: _stock?.title ?? 'Categoria',
                    ),
              ),
            );
          },
        );
      },
    );
  }

  // Aplica o filtro de status aos itens
  List<Item> _applyStatusFilter(List<Item> items) {
    if (_selectedStatusFilter == null) {
      return List.from(items);
    }
    return items.where((item) => item.status == _selectedStatusFilter).toList();
  }

  // Atualiza o filtro de status
  void _updateStatusFilter(ItemStatus? status) {
    setState(() {
      _selectedStatusFilter = status;
      _filteredItems = _applyStatusFilter(_items);
    });
  }

  // Widget do filtro de status
  Widget _buildStatusFilter() {
    return SizedBox(
      width: 160,
      child: SelectField<ItemStatus?>(
        underlineVariant: true,
        value: _selectedStatusFilter,
        hint: 'Filtrar',
        icon: LucideIcons.settings,
        items: [
          const DropdownMenuItem<ItemStatus?>(
            value: null,
            child: Text('Todos'),
          ),
          ...ItemStatus.values.map((status) {
            return DropdownMenuItem<ItemStatus?>(
              value: status,
              child: Text(StatusUtils.getStatusText(status.value)),
            );
          }).toList(),
        ],
        onChanged: _updateStatusFilter,
      ),
    );
  }

  // Widget para construir o header fixo com informações da categoria
  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CustomColors.white,
        boxShadow: [
          BoxShadow(
            color: CustomColors.textPrimary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _stock?.title ?? 'Categoria',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CustomColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: CustomColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (_stock?.borrowedQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Em uso',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CustomColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                      (_stock?.availableQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Disponíveis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: CustomColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                      (_stock?.maintenanceQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Manutenção',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Contador de itens e filtro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Contador de itens
              Text(
                '${_filteredItems.length} item${_filteredItems.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CustomColors.textSecondary,
                ),
              ),
              // Filtro de status
              _buildStatusFilter(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(title: _stock?.title ?? 'Categoria'),
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Adiciona a animação de bounce
        slivers: [
          // Header da imagem
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: false,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImage(),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Header fixo com informações da categoria
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 170.0,
              maxHeight: 170.0,
              child: _buildCategoryHeader(),
            ),
          ),

          // Conteúdo principal
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Container(
                color: CustomColors.white,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.x, size: 64, color: CustomColors.error),
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
                        style: TextStyle(color: CustomColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _initializeData(forceRefresh: true);
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_filteredItems.isEmpty)
            SliverFillRemaining(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(16.0),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.package, size: 64, color: Colors.grey),
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
                ),
              ),
            )
          else
            // Lista de itens usando SliverList para melhor performance e scroll
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < _filteredItems.length) {
                  final item = _filteredItems[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: index == 0 ? 16.0 : 0.0,
                      bottom: index == _filteredItems.length - 1 ? 80.0 : 0.0,
                    ),
                    child: CategoryItemsCard(
                      id: item.id,
                      serialCode: item.serialCode,
                      status: item.status.value,
                      createdAt: item.createdAt,
                    ),
                  );
                }
                return null;
              }, childCount: _filteredItems.length),
            ),

          // Sliver para garantir que sempre há espaço para o scroll bounce
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
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

// Classe para criar um header fixo com SliverPersistentHeader
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
