import 'package:app/core/api/applicants/models/applicants_models.dart';
import 'package:app/core/theme/custom_colors.dart';
import 'package:app/core/widgets/avatar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DependentCard extends StatelessWidget {
  final Dependent dependent;
  final String applicantName;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DependentCard({
    super.key,
    required this.dependent,
    required this.applicantName,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatar(imageUrl: imageUrl, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dependent.name ?? 'Sem nome',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: CustomColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dependent.cpf ?? 'Sem CPF',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Responsável: $applicantName',
                      style: TextStyle(
                        fontSize: 12,
                        color: CustomColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(LucideIcons.pen, color: Colors.amber),
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(LucideIcons.trash, color: Colors.red),
                ),
              if (onTap != null)
                const Icon(
                  LucideIcons.chevronRight,
                  color: CustomColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
