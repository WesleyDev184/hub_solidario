import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/utils/date_utils.dart' as custom_date;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DocumentCard extends StatelessWidget {
  final String name;
  final DateTime createdAt;
  final bool isDependentDoc;
  final VoidCallback? onDownload;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.name,
    required this.createdAt,
    this.isDependentDoc = false,
    this.onDownload,
    this.onEdit,
    this.onDelete,
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
            Icon(LucideIcons.fileText, size: 40, color: CustomColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: CustomColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Criado em: ${custom_date.DateUtils.formatDateBR(createdAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: CustomColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (isDependentDoc)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: CustomColors.onSelected,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Documento de dependente',
                        style: TextStyle(
                          fontSize: 11,
                          color: CustomColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_rounded,
                  color: CustomColors.warning,
                ),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_rounded,
                  color: CustomColors.error,
                ),
              ),
            if (onDownload != null)
              IconButton(
                onPressed: onDownload,
                icon: const Icon(
                  Icons.download_rounded,
                  color: CustomColors.success,
                ),
              ),
          ],
        ),
      ),
    );
    // ...existing code...
  }
}
