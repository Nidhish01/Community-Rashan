import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aunty-first palette: deep grocery green, a Blinkit-ish warm yellow accent,
/// and a readable savings green. Baloo 2 for headings, Mukta for body — both
/// cover Devanagari + Latin for the bilingual UI.
class CR {
  static const green = Color(0xFF15794A);
  static const greenDark = Color(0xFF0F5F3A);
  static const yellow = Color(0xFFF4C233);
  static const yellowInk = Color(0xFF3A2E05);
  static const save = Color(0xFF15794A);
  static const accent = Color(0xFFC47D05);
  static const danger = Color(0xFFB5482F);
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: CR.green,
    brightness: brightness,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  final body = GoogleFonts.muktaTextTheme(base.textTheme);
  final display = GoogleFonts.baloo2TextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge,
    displayMedium: display.displayMedium,
    displaySmall: display.displaySmall,
    headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium: display.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );

  return base.copyWith(
    scaffoldBackgroundColor:
        brightness == Brightness.dark ? const Color(0xFF0F1512) : const Color(0xFFF3F5F2),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: CR.green,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}
