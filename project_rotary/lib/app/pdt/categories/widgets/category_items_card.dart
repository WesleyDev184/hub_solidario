import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';
import 'package:project_rotary/core/utils/utils.dart' as CoreUtils;

class CategoryItemsCard extends StatelessWidget {
  final String id;
  final String serialCode;
  final String status;
  final DateTime createdAt;

  const CategoryItemsCard({
    super.key,
    required this.id,
    required this.serialCode,
    required this.status,
    required this.createdAt,
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
                    serialCode,
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
                  status,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                CoreUtils.StatusUtils.getStatusText(status),
                style: TextStyle(
                  color: CoreUtils.StatusUtils.getStatusColor(status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Row(
              children: [
                IconButton(
                  onPressed: () {},
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
