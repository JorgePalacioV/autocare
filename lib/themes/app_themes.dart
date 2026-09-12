import 'package:flutter/material.dart';

class AppThemes {
  static const Color _primaryColor = Color(0xFF1A73E8);
  static const Color _primaryDark = Color(0xFF1A73E8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      dividerColor: Colors.grey[200],
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        labelStyle: const TextStyle(color: Colors.black87),
        selectedColor: _primaryColor,
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primaryDark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryDark,
          side: const BorderSide(color: _primaryDark, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        labelStyle: const TextStyle(color: Colors.white),
        selectedColor: _primaryDark,
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
    );
  }
}
