import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor:
          const Color.fromARGB(255, 147, 186, 149), // Your primary green color
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 27, 62, 29),
        ).primary,
      ),
      bodyMedium: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 106, 167, 109), //appbar
      ).primary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 101, 147, 104),
        ).onPrimary,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A671E),
      brightness: Brightness.dark,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A671E),
        ).primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.grey[300],
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A671E),
      ).primary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A671E),
        ).onPrimary,
      ),
    ),
  );
}
