import 'package:flutter/material.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CustomColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
