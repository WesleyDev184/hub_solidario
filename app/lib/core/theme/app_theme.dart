import 'package:flutter/material.dart';

import 'custom_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: CustomColors.primary,
  colorScheme:
      ColorScheme.fromSwatch(
        primarySwatch: CustomColors.primarySwatch,
        accentColor: CustomColors.secondary,
        errorColor: CustomColors.error,
      ).copyWith(
        secondary: CustomColors.secondary,
        surface: CustomColors.white,
        onPrimary: CustomColors.white,
        onSecondary: CustomColors.white,
        onSurface: CustomColors.textPrimary,
        onError: CustomColors.white,
      ),
  scaffoldBackgroundColor: CustomColors.background,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: CustomColors.textPrimary),
    bodyMedium: TextStyle(color: CustomColors.textSecondary),
    titleLarge: TextStyle(color: CustomColors.textPrimary),
    titleMedium: TextStyle(color: CustomColors.textSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: CustomColors.primary,
    foregroundColor: CustomColors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: CustomColors.white),
    titleTextStyle: TextStyle(
      color: CustomColors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: CustomColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: CustomColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: CustomColors.primary),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: CustomColors.error),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: CustomColors.error),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: const TextStyle(color: CustomColors.textSecondary),
    hintStyle: const TextStyle(color: CustomColors.textSecondary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: CustomColors.primary,
      foregroundColor: CustomColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: CustomColors.primary,
      side: const BorderSide(color: CustomColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: CustomColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  iconTheme: const IconThemeData(color: CustomColors.primary),
  dividerColor: CustomColors.border,
  snackBarTheme: SnackBarThemeData(
    backgroundColor: CustomColors.primary,
    contentTextStyle: const TextStyle(color: CustomColors.white),
    actionTextColor: CustomColors.secondary,
  ),
);
