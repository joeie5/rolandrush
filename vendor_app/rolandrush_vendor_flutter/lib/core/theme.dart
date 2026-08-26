import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported from the Magic Patterns vendor UI's tailwind.config.
class AppColors {
  static const canvas = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const inkMuted = Color(0xFF6B7076);
  static const inkSubtle = Color(0xFF9DA2A9);
  static const line = Color(0xFFEDEEF0);
  static const lineStrong = Color(0xFFE1E3E7);
  static const coral = Color(0xFFFF3B4E);
  static const coralHover = Color(0xFFEE2A3D);
  static const coralSoft = Color(0xFFFFEDEF);
  static const good = Color(0xFF0E9F58);
  static const goodSoft = Color(0xFFE8F7EF);
  static const warn = Color(0xFFB26A00);
  static const warnSoft = Color(0xFFFDF3E4);
  static const info = Color(0xFF2563C7);
  static const infoSoft = Color(0xFFEAF1FC);
}

class AppRadius {
  static const card = 16.0;
  static const btn = 12.0;
  static const sheet = 24.0;
}

class AppShadows {
  static const card = [BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1))];
  static const elevated = [BoxShadow(color: Color(0x2E101828), blurRadius: 28, offset: Offset(0, 10))];
  static const alert = [BoxShadow(color: Color(0x73FF3B4E), blurRadius: 24, offset: Offset(0, 10))];
}

class AppTheme {
  /// Numeric/display font (Manrope) — amounts, headings.
  static TextStyle num({double size = 15, FontWeight weight = FontWeight.w700, Color color = AppColors.ink}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color, letterSpacing: -0.02 * size);

  /// Body font (Inter).
  static TextStyle sans({double size = 14, FontWeight weight = FontWeight.w400, Color color = AppColors.ink}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.coral);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: base.colorScheme.copyWith(primary: AppColors.coral),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: sans(size: 17, weight: FontWeight.w700),
      ),
    );
  }
}
