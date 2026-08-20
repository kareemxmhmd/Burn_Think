import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF08090A);
  static const Color backgroundSecondary = Color(0xFF0D0E10);
  static const Color sidebar = Color(0xFF171719);
  static const Color surfaceDark = Color(0xFF1B1C1F);

  // Typography
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB7B7BA);
  static const Color textTertiary = Color(0xFF858589);
  static const Color textDisabled = Color(0xFF5D5D61);

  // Glass Material System
  static const Color glassSubtle = Color(0x0AFFFFFF); // ~4%
  static const Color glassStandard = Color(0x11FFFFFF); // ~6.7%
  static const Color glassElevated = Color(0x1CFFFFFF); // ~11%
  static const Color glassDark = Color(0x09FFFFFF); // ~3.5%

  static const Color glassBorderSubtle = Color(0x1AFFFFFF); // ~10%
  static const Color glassBorderStandard = Color(0x1FFFFFFF); // ~12%
  static const Color glassBorderStrong = Color(0x2EFFFFFF); // ~18%

  static const Color glassHighlight = Color(0x1AFFFFFF); // ~10%
  static const Color glassHover = Color(0x0AFFFFFF); // ~4%
  static const Color glassActive = Color(0x19FFFFFF); // ~10%

  // Accents / Monochromatic Metallic
  static const Color metallicWhite = Color(0xFFFFFFFF);
  static const Color metallicSilver = Color(0xFFC0C0C6);
  static const Color metallicDark = Color(0xFF2A2B2F);

  static const LinearGradient metallicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFD4D4D8),
      Color(0xFFA1A1AA),
    ],
  );

  static const LinearGradient glassReflectionGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x14FFFFFF),
      Color(0x00FFFFFF),
    ],
  );

  // Destructive / Danger (Strictly for explicit deletion & reset confirmations)
  static const Color danger = Color.fromARGB(255, 120, 0, 0);
  static const Color dangerSurface = Color(0x1AE55353);
  static const Color dangerBorder = Color(0x33E55353);
}
