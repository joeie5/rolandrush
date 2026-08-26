import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported 1:1 from the Magic Patterns rider UI's
/// tailwind.config.js (rider_app_ui_src/tailwind.config.js). Kept local to
/// this app (like the customer/vendor apps each keep their own theme.dart)
/// rather than shared, since these are separate Flutter projects.
class AppColors {
  static const canvas = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const inkMuted = Color(0xFF6B6B6B);
  static const inkFaint = Color(0xFF9A9A9A);
  static const line = Color(0xFFEAEAEA);

  static const coral = Color(0xFFFF3B4E);
  static const coralHover = Color(0xFFE62E40);
  static const coralSoft = Color(0xFFFFECEE);

  /// "online" in the React tokens — also used for success/verified states.
  static const online = Color(0xFF12B76A);
  static const onlineHover = Color(0xFF0E9A59);
  static const onlineSoft = Color(0xFFE4F8EE);

  /// "alert" in the React tokens — used for high-pay badges, warnings and
  /// pending-verification states (amber, not destructive-red).
  static const alert = Color(0xFFF79009);
  static const alertHover = Color(0xFFDD7B03);
  static const alertSoft = Color(0xFFFFF3E2);
}

class AppRadius {
  static const card = 16.0;
  static const btn = 12.0;
}

class AppShadows {
  static const float = [BoxShadow(color: Color(0x2E1A1A1A), blurRadius: 24, offset: Offset(0, 8))];
  static const sheet = [BoxShadow(color: Color(0x381A1A1A), blurRadius: 30, offset: Offset(0, -10))];
}

class AppTheme {
  static TextStyle sans({double size = 15, FontWeight weight = FontWeight.w500, Color color = AppColors.ink, double? letterSpacing}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.coral, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      colorScheme: base.colorScheme.copyWith(primary: AppColors.coral, surface: AppColors.surface),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.ink,
        titleTextStyle: sans(size: 17, weight: FontWeight.w800),
      ),
    );
  }
}
