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

  Widget _buildImage() {
    // Verifica se é uma URL web (começa com http:// ou https://)
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.image,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagem não encontrada',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    strokeWidth: 2,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Carregando...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // É um asset local
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.image,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagem não encontrada',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

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
              child: _buildImage(),
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
                      LucideIcons.clock,
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
