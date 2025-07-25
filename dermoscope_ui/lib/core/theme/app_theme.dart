import 'package:flutter/material.dart';

class AppTheme {
  static const Color successLight = Color(0xFF4CAF50);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color errorLight = Color(0xFFF44336);
  static const Color shadowLight = Color(0x11000000);
  static const Color accentLight = Color(0xFF64B5F6);

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1976D2),
      primaryContainer: Color(0xFFE3F2FD),
      secondary: Color(0xFFFFC107),
      error: Color(0xFFF44336),
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.black54,
      outline: Colors.grey,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      bodySmall: TextStyle(fontSize: 12, color: Colors.black54),
      labelSmall: TextStyle(fontSize: 11, color: Colors.black54),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
