import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Theme Colors ---
  static const darkBackground = Color(0xFF0B0F19);
  static const darkSurface = Color(0xFF111827);
  static const darkCard = Color(0xFF151C2B);
  static const darkSidebar = Color(0xFF0D1322);
  static const darkBorder = Color(0xFF243044);
  static const darkDivider = Color(0xFF1D2636);
  static const darkText = Color(0xFFE8EEF6);
  static const darkTextSecondary = Color(0xFF96A3B8);
  static const darkTextMuted = Color(0xFF657089);

  // --- Light Theme Colors ---
  static const lightBackground = Color(0xFFF5F7FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightSidebar = Color(0xFFEEF2F8);
  static const lightBorder = Color(0xFFD7DEEA);
  static const lightDivider = Color(0xFFE3E8F0);
  static const lightText = Color(0xFF1B2230);
  static const lightTextSecondary = Color(0xFF556178);
  static const lightTextMuted = Color(0xFF7A879F);

  // --- Accent Colors ---
  static const accent = Color(0xFF00D2B8);
  static const accentLight = Color(0xFF52F2E1);
  static const accentDark = Color(0xFF00A88F);
  static const accentSecondary = Color(0xFFFFC857);
  static const accentIndigo = Color(0xFF1F6FEB);
  static const brandDark = Color(0xFF141414);
  static const brandLight = Color(0xFFFFFFFF);

  // --- Status Colors ---
  static const running = Color(0xFF3FB950);
  static const stopped = Color(0xFFF85149);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF38BDF8);

  // --- Service Brand Colors ---
  static const apache = Color(0xFFD22128);
  static const mysql = Color(0xFF00758F);
  static const php = Color(0xFF777BB4);
  static const redis = Color(0xFFDC382D);
  static const nodejs = Color(0xFF339933);
  static const laravel = Color(0xFFFF2D20);
  static const react = Color(0xFF61DAFB);
  static const vue = Color(0xFF4FC08D);
  static const python = Color(0xFF3776AB);
  static const django = Color(0xFF092E20);
  static const fastapi = Color(0xFF009688);
  static const svelte = Color(0xFFFF3E00);
  static const angular = Color(0xFFDD0031);
  static const nuxt = Color(0xFF00DC82);
  static const wordpress = Color(0xFF21759B);
  static const smtp = Color(0xFF7C3AED);
  static const websocket = Color(0xFF10B981);

  // --- Gradients ---
  static const accentGradient = LinearGradient(
    colors: [Color(0xFF00D2B8), Color(0xFFFFC857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const shellGradientDark = LinearGradient(
    colors: [Color(0xFF0B0F19), Color(0xFF101827), Color(0xFF0B1220)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const shellGradientLight = LinearGradient(
    colors: [Color(0xFFF5F7FB), Color(0xFFF9FBFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
