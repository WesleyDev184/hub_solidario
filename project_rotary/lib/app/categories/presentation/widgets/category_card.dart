import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  final int available;
  final int inUse;
  final int inMaintenance;

  const CategoryCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.available,
    required this.inUse,
    required this.inMaintenance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.check,
                      color: CustomColors.success,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(available.toString()),
                    SizedBox(width: 16),
                    Icon(
                      LucideIcons.wrench,
                      color: CustomColors.error,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(inMaintenance.toString()),
                    SizedBox(width: 16),
                    Icon(
                      LucideIcons.star,
                      color: CustomColors.warning,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(inUse.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
