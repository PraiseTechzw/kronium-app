import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF0C8A44);
  static const Color secondaryColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color infoColor = Color(0xFF3498DB);
  static const Color successColor = Color(0xFF27AE60);

  // Backgrounds and surfaces
  static const Color backgroundLight = Color(0xFFF9F9F9);
  static const Color backgroundDark = Color(0xFF181A20);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF23262B);

  // Text colors
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Colors.white;
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Icon colors
  static const Color iconPrimary = primaryColor;
  static const Color iconSecondary = secondaryColor;
  static const Color iconDisabled = Color(0xFFBDBDBD);

  // Divider and border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFDDDDDD);

  // Shadow
  static const Color shadow = Color(0x1A000000); // 10% opacity black

  // Disabled state
  static const Color disabled = Color(0xFFEEEEEE);

  // Card
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF23262B);

  // AppBar
  static const Color appBarLight = Colors.white;
  static const Color appBarDark = Color(0xFF23262B);

  // Button
  static const Color buttonPrimary = primaryColor;
  static const Color buttonSecondary = secondaryColor;
  static const Color buttonDisabled = disabled;

  // Snackbar
  static const Color snackbarBackground = Color(0xFF323232);
  static const Color snackbarText = Colors.white;

  // Main theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: appBarLight,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardColor: cardLight,
    dividerColor: divider,
    disabledColor: disabled,
    shadowColor: shadow,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimary,
        elevation: 8,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: snackbarBackground,
      contentTextStyle: TextStyle(color: snackbarText),
    ),
    iconTheme: const IconThemeData(color: iconPrimary),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      bodySmall: TextStyle(color: textDisabled),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textSecondary),
      titleSmall: TextStyle(color: textDisabled),
    ),
  );
}