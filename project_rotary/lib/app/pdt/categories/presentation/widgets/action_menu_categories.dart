import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class ActionMenuCategories extends StatelessWidget {
  final VoidCallback? onCreatePressed;
  final String title;

  const ActionMenuCategories({
    super.key,
    this.onCreatePressed,
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
            icon: LucideIcons.plus,
            title: 'Criar',
            subtitle: 'Criar nova categoria',
            onTap: () {
              Navigator.pop(context);
              onCreatePressed?.call();
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
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              isDestructive
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
