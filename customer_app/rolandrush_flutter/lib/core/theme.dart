import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported from the Magic Patterns export's tailwind.config.js.
class AppColors {
  static const coral = Color(0xFFFF3B4E);
  static const coral600 = Color(0xFFEE2B3E);
  static const coral700 = Color(0xFFCC1F30);
  static const coralSoft = Color(0xFFFFEDEF);
  static const ink = Color(0xFF1A1A1A);
  static const ink70 = Color(0xFF4A4A4A);
  static const ink50 = Color(0xFF6B6B6B);
  static const ink35 = Color(0xFF9A9A9A);
  static const canvas = Color(0xFFFAFAFA);
  static const line = Color(0xFFECECEC);
  static const night = Color(0xFF0B0B0C);
  static const mint = Color(0xFF0FA968);
}

class AppRadius {
  static const card = 20.0;
  static const sheet = 28.0;
  static const btn = 12.0;
  static const chip = 12.0;
}

class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0A101010), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const float = [
    BoxShadow(color: Color(0x52FF3B4E), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const sheet = [
    BoxShadow(color: Color(0x24000000), blurRadius: 40, offset: Offset(0, -12)),
  ];
}

class AppTheme {
  static TextStyle display({
    double size = 15,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? letterSpacing,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing ?? -0.02 * size,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.coral);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: base.colorScheme.copyWith(primary: AppColors.coral),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: display(size: 18, weight: FontWeight.w800),
      ),
    );
  }
}
