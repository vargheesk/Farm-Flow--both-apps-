import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF1A2036);
  static const Color darkSecondary = Color(0xFF3F88C5);
  static const Color darkCard = Color(0xFF252D4A);
  static const Color darkText = Color(0xFFE6EBF2);
  static const Color darkSecondaryText = Color(0xFFACBBD3);
  static const Color darkDivider = Color(0xFF404B69);
  static const Color darkSurface = Color(0xFF212940);
  static const Color darkBackground = Color(0xFF1A2036);

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFFF8F9FA);
  static const Color lightSecondary = Color(0xFF0D47A1);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A2036);
  static const Color lightSecondaryText = Color(0xFF5A6888);
  static const Color lightDivider = Color(0xFFE1E5EB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF8F9FA);

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color errorColor = Color(0xFFE53935);
  static const Color infoColor = Color(0xFF2196F3);

  // Theme state
  static bool _isDarkMode = false;
  static bool get isDarkMode => _isDarkMode;
  static set isDarkMode(bool value) {
    _isDarkMode = value;
  }

  // Get theme-specific colors
  static Color get primaryColor => _isDarkMode ? darkPrimary : lightPrimary;
  static Color get secondaryColor =>
      _isDarkMode ? darkSecondary : lightSecondary;
  static Color get cardColor => _isDarkMode ? darkCard : lightCard;
  static Color get textColor => _isDarkMode ? darkText : lightText;
  static Color get secondaryTextColor =>
      _isDarkMode ? darkSecondaryText : lightSecondaryText;
  static Color get dividerColor => _isDarkMode ? darkDivider : lightDivider;
  static Color get surfaceColor => _isDarkMode ? darkSurface : lightSurface;
  static Color get backgroundColor =>
      _isDarkMode ? darkBackground : lightBackground;

  static ThemeData getCurrentTheme() {
    return _isDarkMode ? _getDarkTheme() : _getLightTheme();
  }

  static ThemeData _getDarkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: darkSecondary,
      onPrimary: darkText,
      primaryContainer: darkSecondary.withOpacity(0.7),
      onPrimaryContainer: darkText,
      secondary: darkSecondary,
      onSecondary: darkText,
      secondaryContainer: darkSecondary.withOpacity(0.5),
      onSecondaryContainer: darkText,
      surface: darkSurface,
      onSurface: darkText,
      surfaceVariant: darkCard,
      onSurfaceVariant: darkText,
      background: darkBackground,
      onBackground: darkText,
      error: errorColor,
      onError: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: darkPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: darkPrimary,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: const TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: darkText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: darkText),
        bodyMedium: TextStyle(color: darkSecondaryText),
      ),
      dividerColor: darkDivider,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkSecondary,
        foregroundColor: darkText,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        labelStyle: const TextStyle(color: darkSecondaryText),
        hintStyle: const TextStyle(color: darkSecondaryText),
        floatingLabelStyle: const TextStyle(color: darkSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkSecondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkSecondary,
          foregroundColor: darkText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return darkSecondary;
          }
          return darkSecondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return darkSecondary.withOpacity(0.5);
          }
          return darkSecondaryText.withOpacity(0.5);
        }),
      ),
    );
  }

  static ThemeData _getLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: lightSecondary,
      onPrimary: Colors.white,
      primaryContainer: lightSecondary.withOpacity(0.7),
      onPrimaryContainer: Colors.white,
      secondary: lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: lightSecondary.withOpacity(0.5),
      onSecondaryContainer: Colors.white,
      surface: lightSurface,
      onSurface: lightText,
      surfaceVariant: lightCard,
      onSurfaceVariant: lightText,
      background: lightBackground,
      onBackground: lightText,
      error: errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: lightText),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: lightPrimary,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: lightText,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightSecondaryText),
      ),
      dividerColor: lightDivider,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightSecondary,
        foregroundColor: Colors.white,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        labelStyle: const TextStyle(color: lightSecondaryText),
        hintStyle: const TextStyle(color: lightSecondaryText),
        floatingLabelStyle: const TextStyle(color: lightSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightSecondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightSecondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightSecondary;
          }
          return lightSecondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return lightSecondary.withOpacity(0.5);
          }
          return lightSecondaryText.withOpacity(0.5);
        }),
      ),
    );
  }

  // Helper function to get appropriate color based on theme mode
  static Color getAdaptiveColor(
      {required Color darkColor, required Color lightColor}) {
    return _isDarkMode ? darkColor : lightColor;
  }

  // Status indicator colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return successColor;
      case 'pending':
      case 'verification pending':
        return warningColor;
      case 'rejected':
        return errorColor;
      default:
        return infoColor;
    }
  }
}
