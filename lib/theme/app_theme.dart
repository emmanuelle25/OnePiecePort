import 'package:flutter/material.dart';

class AppTheme {
  static const vermelho = Color(0xFFE52B2B);
  static const vermelhoEscuro = Color(0xFF8F1824);
  static const dourado = Color(0xFFFFC928);
  static const azul = Color(0xFF1769AA);
  static const marinho = Color(0xFF0A1E36);
  static const azulClaro = Color(0xFFEAF3FF);
  static const pergaminho = Color(0xFFF8F8F4);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: vermelho, brightness: Brightness.light).copyWith(
      primary: vermelho, secondary: dourado, surface: pergaminho,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pergaminho,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: marinho, foregroundColor: Colors.white, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: dourado.withValues(alpha: .28),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: marinho.withValues(alpha: .10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.black.withValues(alpha: .05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: vermelho, width: 1.5)),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: vermelho, brightness: Brightness.dark).copyWith(primary: vermelho, secondary: dourado);
    return ThemeData(
      useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF07121F),
      appBarTheme: const AppBarTheme(backgroundColor: marinho, foregroundColor: Colors.white, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: const Color(0xFF0C1D2E), indicatorColor: dourado.withValues(alpha: .22)),
      cardTheme: CardThemeData(elevation: 0, margin: EdgeInsets.zero, color: const Color(0xFF10263D), surfaceTintColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: const Color(0xFF10263D), contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
    );
  }
}
