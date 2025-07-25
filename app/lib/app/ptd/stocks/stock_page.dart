import 'package:app/app/ptd/stocks/widgets/action_menu_stock.dart';
import 'package:app/app/ptd/stocks/widgets/stock_items_card.dart';
import 'package:app/core/api/api.dart';
import 'package:app/core/api/stocks/models/items_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/status_utils.dart';
import 'package:app/core/widgets/appbar_custom.dart';
import 'package:app/core/widgets/select_field.dart';
import 'package:app/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class StockPage extends StatefulWidget {
  final String id;

  const StockPage({super.key, required this.id});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final StocksController _stockController = Get.find<StocksController>();
  Stock? _stock;
  // Listagem dos itens
  List<Item> _filteredItems = [];
  // Filtro de status
  ItemStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStock();
    });
  }

  Future<void> _loadStock() async {
    final result = await _stockController.getStockById(widget.id);
    result.fold((stock) {
      setState(() {
        _stock = stock;
        // Inicializa os itens a partir do stock
        _filteredItems = _applyStatusFilter(stock.items ?? []);
      });
    }, (failure) => _stockController.error = failure.toString());
  }

  @override
  void dispose() {
    _filteredItems.clear();
    _selectedStatusFilter = null;
    _stock = null;
    super.dispose();
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
          cacheWidth:
              412, // Sugere ao Flutter decodificar próximo ao tamanho exibido
          cacheHeight: 260,
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
                      value: loadingProgress.expectedTotalBytes != null
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
        return ActionMenuStock(
          availableQtd: _stock?.availableQtd ?? 0,
          onCreatePressed: () {
            context.go(RoutePaths.ptd.addItem(_stock?.id ?? ''));
          },
          onEditPressed: () {
            context.go(RoutePaths.ptd.editStock(_stock?.id ?? ''));
          },
          onDeletePressed: () {
            context.go(RoutePaths.ptd.deleteStock(_stock?.id ?? ''));
          },
          onBorrowPressed: () {},
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
      _filteredItems = _applyStatusFilter(_stock?.items ?? []);
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
          }),
        ],
        onChanged: _updateStatusFilter,
      ),
    );
  }

  // Widget para construir o header fixo com informações da categoria
  Widget _buildCategoryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nome da categoria
          Text(
            _stock?.title ?? 'Categoria',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: 4),
          // Badges responsivas
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Em uso
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: CustomColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.clock,
                      color: CustomColors.warning,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      (_stock?.borrowedQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Em uso',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              // Disponíveis
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CustomColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.check,
                      color: CustomColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      (_stock?.availableQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Disponíveis',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              // Manutenção
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CustomColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.wrench,
                      color: CustomColors.error,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      (_stock?.maintenanceQtd ?? 0).toString(),
                      style: const TextStyle(
                        color: CustomColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Manutenção',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Contador de itens e filtro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Contador de itens
              Text(
                '${_filteredItems.length} item${_filteredItems.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 14,
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
          SliverToBoxAdapter(child: _buildCategoryHeader()),

          // Conteúdo principal
          if (_stockController.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
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
                    child: StockItemsCard(
                      id: item.id,
                      serialCode: item.serialCode,
                      status: item.status,
                      createdAt: item.createdAt,
                      stockId: widget.id,
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
