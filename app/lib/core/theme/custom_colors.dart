import 'package:flutter/material.dart';

class CustomColors {
  static const Color primary = Color(0xFF0051A8);
  static const Color secondary = Color(0xFF14BAFF);
  static const Color background = Color(0xFFF6F5F5);

  static const Color textPrimary = Color(0xFF2D0C57);
  static const Color textSecondary = Color(0xFF9586A8);
  static const Color onSelected = Color(0xFFE2CBFF);
  static const Color border = Color(0xFFD9D0E3);
  static const Color success = Color(0xFF0BCE83);
  static const Color error = Color(0xFFFF5151);
  static const Color warning = Color(0xFFD9C96F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF3B82F6);

  // Caso precise de um MaterialColor para, por exemplo, definir o tema:
  static MaterialColor primarySwatch =
      MaterialColor(primary.value, <int, Color>{
        50: primary.withOpacity(0.1),
        100: primary.withOpacity(0.2),
        200: primary.withOpacity(0.3),
        300: primary.withOpacity(0.4),
        400: primary.withOpacity(0.5),
        500: primary.withOpacity(0.6),
        600: primary.withOpacity(0.7),
        700: primary.withOpacity(0.8),
        800: primary.withOpacity(0.9),
        900: primary.withOpacity(1.0),
      });
}
