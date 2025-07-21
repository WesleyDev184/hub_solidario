import 'package:app/core/api/loans/models/items_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/utils.dart' as CoreUtils;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoryItemsCard extends StatelessWidget {
  final String id;
  final int serialCode;
  final ItemStatus status;
  final DateTime createdAt;

  final String stockId;

  const CategoryItemsCard({
    super.key,
    required this.id,
    required this.serialCode,
    required this.status,
    required this.createdAt,
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
                  onPressed: () {
                    debugPrint('Delete item $id');
                  },
                  icon: Icon(LucideIcons.trash, color: Colors.red),
                ),
                IconButton(
                  onPressed: () {
                    debugPrint('Edit item $id');
                  },
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
