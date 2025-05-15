import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/components/avatar.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class ApplicantsCard extends StatelessWidget {
  final String id;
  final String? imageUrl;
  final String name;
  final int qtd;
  final bool beneficiary;

  const ApplicantsCard({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.qtd,
    required this.beneficiary,
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
            Avatar(imageUrl: imageUrl, size: 48),
            const SizedBox(width: 12),
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    beneficiary ? 'É beneficiário' : 'Tem beneficiários ($qtd)',
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}
