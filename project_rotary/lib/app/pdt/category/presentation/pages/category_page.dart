import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/category/presentation/widgets/category_items_card.dart';
import 'package:project_rotary/core/components/appbar_custom.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

final List<Map<String, dynamic>> mockApiResponse = List.generate(10, (index) {
  final statuses = ['Emprestado', 'Em manutenção', 'Disponível'];
  return {
    'id': '${index + 1}',
    'serialCode': 'SC-${(index + 1).toString().padLeft(4, '0')}',
    'status': statuses[index % statuses.length],
    'createdAt': '2025-05-${(17 - index).toString().padLeft(2, '0')}',
  };
});

class CategoryPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarCustom(title: categoryTitle),
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
                child: Stack(
                  children: [
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        bottom: 80,
                      ), // espaço para o botão
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              categoryTitle,
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
                                inUse.toString(),
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
                                    available.toString(),
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
                                    inMaintenance.toString(),
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
                        Column(
                          children:
                              mockApiResponse
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: CategoryItemsCard(
                                        id: item['id'],
                                        serialCode: item['serialCode'],
                                        status: item['status'],
                                        createdAt: DateTime.parse(
                                          item['createdAt'],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Button(
                        onPressed: () {},
                        text: 'Emprestar',
                        backgroundColor: CustomColors.success,
                        icon: Icon(
                          LucideIcons.layoutList,
                          color: CustomColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
