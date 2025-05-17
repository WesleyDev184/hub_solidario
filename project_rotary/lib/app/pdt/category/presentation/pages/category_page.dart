import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/category/presentation/widgets/category_items_card.dart';
import 'package:project_rotary/core/components/button.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

final List<Map<String, dynamic>> mockApiResponse = [
  {
    'id': '1',
    'serialCode': 'SC-0001',
    'status': 'Emprestado',
    'createdAt': '2025-05-17',
  },
  {
    'id': '2',
    'serialCode': 'SC-0002',
    'status': 'Em manutenção',
    'createdAt': '2025-05-16',
  },
  {
    'id': '3',
    'serialCode': 'SC-0003',
    'status': 'Disponível',
    'createdAt': '2025-05-15',
  },
  {
    'id': '4',
    'serialCode': 'SC-0004',
    'status': 'Emprestado',
    'createdAt': '2025-05-14',
  },
  {
    'id': '5',
    'serialCode': 'SC-0005',
    'status': 'Em manutenção',
    'createdAt': '2025-05-13',
  },
  {
    'id': '6',
    'serialCode': 'SC-0006',
    'status': 'Disponível',
    'createdAt': '2025-05-12',
  },
  {
    'id': '7',
    'serialCode': 'SC-0007',
    'status': 'Emprestado',
    'createdAt': '2025-05-11',
  },
  {
    'id': '8',
    'serialCode': 'SC-0008',
    'status': 'Em manutenção',
    'createdAt': '2025-05-10',
  },
  {
    'id': '9',
    'serialCode': 'SC-0009',
    'status': 'Disponível',
    'createdAt': '2025-05-09',
  },
  {
    'id': '10',
    'serialCode': 'SC-0010',
    'status': 'Emprestado',
    'createdAt': '2025-05-08',
  },
];

class CategoryPage extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const CategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 270.0,
                floating: false,
                pinned: true,
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
            initialChildSize: 0.72,
            minChildSize: 0.7,
            maxChildSize: 0.94,
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
                                '5',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                                  const Text(
                                    '3',
                                    style: TextStyle(
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
                                  const Text(
                                    '3',
                                    style: TextStyle(
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
