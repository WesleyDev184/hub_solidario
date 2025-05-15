import 'package:flutter/material.dart';
import 'package:project_rotary/core/theme/custom_colors.dart';

class Button extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final bool isFullWidth;

  const Button({
    super.key,
    this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // ajuste para o grau desejado
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child:
          (text == null || text!.isEmpty)
              ? ElevatedButton(
                onPressed: onPressed,
                style: buttonStyle,
                child: icon ?? const SizedBox.shrink(),
              )
              : ElevatedButton.icon(
                onPressed: onPressed,
                style: buttonStyle,
                icon: icon ?? const SizedBox.shrink(),
                label: Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor ?? CustomColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
    );
  }
}
