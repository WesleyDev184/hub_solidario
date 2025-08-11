import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color? color;
  final Widget? icon;
  final bool isFullWidth;
  final String? subtitle;

  const Button({
    super.key,
    this.text,
    required this.onPressed,
    this.color,
    this.icon,
    this.isFullWidth = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? CustomColors.primary;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: buttonColor.withOpacity(0.1), width: 1),
            ),
            child: Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: buttonColor, size: 20),
                    child: icon!,
                  ),
                  if (text != null && text!.isNotEmpty)
                    const SizedBox(width: 12),
                ],
                if (text != null && text!.isNotEmpty)
                  Expanded(
                    flex: isFullWidth ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          text!,
                          style: TextStyle(
                            color: CustomColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: CustomColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
