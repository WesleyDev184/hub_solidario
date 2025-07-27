import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActionMenuStock extends StatelessWidget {
  final VoidCallback? onCreatePressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onBorrowPressed;
  final String title;
  final int availableQtd;

  const ActionMenuStock({
    super.key,
    this.onCreatePressed,
    this.onEditPressed,
    this.onDeletePressed,
    this.onBorrowPressed,
    this.title = 'Ações',
    this.availableQtd = 0,
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
            icon: LucideIcons.plus,
            title: 'Adicionar',
            subtitle: 'Adicionar novo item',
            onTap: () {
              Navigator.pop(context);
              onCreatePressed?.call();
            },
          ),
          _buildActionItem(
            context,
            icon: LucideIcons.pencil,
            title: 'Editar',
            subtitle: 'Editar categoria',
            onTap: () {
              Navigator.pop(context);
              onEditPressed?.call();
            },
          ),
          if (availableQtd > 0)
            _buildActionItem(
              context,
              icon: LucideIcons.layoutList,
              title: 'Emprestar',
              subtitle: "Criar novo empréstimo",
              onTap: () {
                Navigator.pop(context);
                onBorrowPressed?.call();
              },
            ),
          _buildActionItem(
            context,
            icon: LucideIcons.trash2,
            title: 'Deletar',
            subtitle: 'Deletar categoria',
            onTap: () {
              Navigator.pop(context);
              onDeletePressed?.call();
            },
            isDestructive: true,
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
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? CustomColors.error.withOpacity(0.1)
              : CustomColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? CustomColors.error : CustomColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? CustomColors.error : CustomColors.textPrimary,
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
