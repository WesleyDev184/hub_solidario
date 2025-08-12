import 'package:app/core/theme/custom_colors.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;

  const Button({
    super.key,
    this.text,
    required this.onPressed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Define a cor de fundo padrão se nenhuma for fornecida
    final Color background = color ?? CustomColors.primary;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bordas arredondadas
        ),
        elevation: 5, // Sombra do botão
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Para o botão se ajustar ao conteúdo
        children: [
          // Mostra o ícone apenas se ele for fornecido
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 22.0),
            const SizedBox(width: 10.0), // Espaçamento entre o ícone e o text
          ],
          if (text != null) ...[
            Text(
              text!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
