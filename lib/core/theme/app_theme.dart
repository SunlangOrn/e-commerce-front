import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFFF7F7FA),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}