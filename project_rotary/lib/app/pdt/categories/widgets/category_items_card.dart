import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/app/pdt/categories/pages/delete_item_page.dart';
import 'package:project_rotary/core/api/api.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class CategoryItemsCard extends StatelessWidget {
  final String id;
  final int serialCode;
  final ItemStatus status;
  final DateTime createdAt;
  final Function() loadItems;
  final String stockId;

  const CategoryItemsCard({
    super.key,
    required this.id,
    required this.serialCode,
    required this.status,
    required this.createdAt,
    required this.loadItems,
    required this.stockId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CoreUtils.Formats.formatSerialCode(serialCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: CustomColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CoreUtils.DateUtils.formatDateBR(createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CoreUtils.StatusUtils.getStatusColor(
                  status.value,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                CoreUtils.StatusUtils.getStatusText(status.value),
                style: TextStyle(
                  color: CoreUtils.StatusUtils.getStatusColor(status.value),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DeleteItemPage(
                              itemId: id,
                              stockId: stockId,
                              itemSerialCode: serialCode,
                              status: status,
                            ),
                      ),
                    );
                    if (res == true) {
                      loadItems.call();
                    }
                  },
                  icon: Icon(LucideIcons.trash, color: Colors.red),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(LucideIcons.pen, color: Colors.amber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
