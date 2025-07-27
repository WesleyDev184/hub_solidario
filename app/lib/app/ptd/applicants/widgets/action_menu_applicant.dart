import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActionMenuApplicant extends StatelessWidget {
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onCreatedPressed;
  final String title;

  const ActionMenuApplicant({
    super.key,
    this.onEditPressed,
    this.onDeletePressed,
    this.onCreatedPressed,
    this.title = 'Ações',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            context,
            icon: LucideIcons.userPlus,
            title: 'Criar beneficiário',
            subtitle: "Crie um beneficiário para o solicitante",
            color: CustomColors.primary,
            onTap: () {
              Navigator.pop(context);
              onCreatedPressed?.call();
            },
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.pen,
            title: 'Editar solicitante',
            subtitle: "Edite os dados do solicitante",
            color: CustomColors.warning,
            onTap: () {
              Navigator.pop(context);
              onEditPressed?.call();
            },
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.trash,
            title: 'Deletar solicitante',
            subtitle: "Delete o solicitante permanentemente",
            color: CustomColors.error,
            onTap: () {
              Navigator.pop(context);
              onDeletePressed?.call();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: CustomColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: CustomColors.textSecondary, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
