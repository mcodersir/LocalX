import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => _buildDark();
  static ThemeData get lightTheme => _buildLight();

  static ThemeData darkThemeWithFonts({required String displayFont, required String bodyFont}) {
    return _buildDark(displayFont: displayFont, bodyFont: bodyFont);
  }

  static ThemeData lightThemeWithFonts({required String displayFont, required String bodyFont}) {
    return _buildLight(displayFont: displayFont, bodyFont: bodyFont);
  }

  static ThemeData _buildDark({String? displayFont, String? bodyFont}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentSecondary,
        surface: AppColors.darkSurface,
        error: AppColors.stopped,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
        onError: AppColors.darkText,
      ),
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkDivider,
      textTheme: _buildTextTheme(Brightness.dark, displayFont: displayFont, bodyFont: bodyFont),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        titleTextStyle: _displayStyle(displayFont, size: 18, weight: FontWeight.w600, color: AppColors.darkText),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w700, color: AppColors.darkText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w700, color: AppColors.darkText),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w400, color: AppColors.darkTextMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return AppColors.darkTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent.withValues(alpha: 0.3);
          return AppColors.darkBorder;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        textStyle: _bodyStyle(bodyFont, size: 12, weight: FontWeight.w500, color: AppColors.darkText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: _bodyStyle(bodyFont, size: 13, weight: FontWeight.w500, color: AppColors.darkText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.2) : AppColors.darkSurface),
          foregroundColor: const WidgetStatePropertyAll(AppColors.darkText),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.darkBorder)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  static ThemeData _buildLight({String? displayFont, String? bodyFont}) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.accentIndigo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentIndigo,
        secondary: AppColors.accentSecondary,
        surface: AppColors.lightSurface,
        error: AppColors.stopped,
        onPrimary: Colors.white,
        onSecondary: AppColors.lightText,
        onSurface: AppColors.lightText,
        onError: Colors.white,
      ),
      cardColor: AppColors.lightCard,
      dividerColor: AppColors.lightDivider,
      textTheme: _buildTextTheme(Brightness.light, displayFont: displayFont, bodyFont: bodyFont),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        titleTextStyle: _displayStyle(displayFont, size: 18, weight: FontWeight.w600, color: AppColors.lightText),
        iconTheme: const IconThemeData(color: AppColors.lightText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w700, color: AppColors.lightText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightText,
          side: const BorderSide(color: AppColors.lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w700, color: AppColors.lightText),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentIndigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w400, color: AppColors.lightTextMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accentIndigo;
          return AppColors.lightTextMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accentIndigo.withValues(alpha: 0.3);
          return AppColors.lightBorder;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
          ],
        ),
        textStyle: _bodyStyle(bodyFont, size: 12, weight: FontWeight.w500, color: AppColors.lightText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightCard,
        contentTextStyle: _bodyStyle(bodyFont, size: 13, weight: FontWeight.w500, color: AppColors.lightText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.accentIndigo.withValues(alpha: 0.2) : AppColors.lightSurface),
          foregroundColor: const WidgetStatePropertyAll(AppColors.lightText),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.lightBorder)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness, {String? displayFont, String? bodyFont}) {
    final color = brightness == Brightness.dark ? AppColors.darkText : AppColors.lightText;
    final secondary = brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: _displayStyle(displayFont, size: 32, weight: FontWeight.w700, color: color, letterSpacing: -0.5),
      displayMedium: _displayStyle(displayFont, size: 28, weight: FontWeight.w700, color: color, letterSpacing: -0.5),
      displaySmall: _displayStyle(displayFont, size: 24, weight: FontWeight.w600, color: color),
      headlineMedium: _displayStyle(displayFont, size: 20, weight: FontWeight.w600, color: color),
      headlineSmall: _displayStyle(displayFont, size: 18, weight: FontWeight.w600, color: color),
      titleLarge: _displayStyle(displayFont, size: 16, weight: FontWeight.w600, color: color),
      titleMedium: _displayStyle(displayFont, size: 14, weight: FontWeight.w500, color: color),
      titleSmall: _displayStyle(displayFont, size: 13, weight: FontWeight.w500, color: secondary),
      bodyLarge: _bodyStyle(bodyFont, size: 15, weight: FontWeight.w400, color: color),
      bodyMedium: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w400, color: color),
      bodySmall: _bodyStyle(bodyFont, size: 12, weight: FontWeight.w400, color: secondary),
      labelLarge: _bodyStyle(bodyFont, size: 14, weight: FontWeight.w700, color: color),
      labelMedium: _bodyStyle(bodyFont, size: 12, weight: FontWeight.w600, color: secondary),
      labelSmall: _bodyStyle(bodyFont, size: 11, weight: FontWeight.w600, color: secondary, letterSpacing: 0.5),
    );
  }

  static TextStyle _displayStyle(String? family, {required double size, required FontWeight weight, required Color color, double? letterSpacing}) {
    if (family == null || family.isEmpty) {
      return GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);
    }
    return TextStyle(fontFamily: family, fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);
  }

  static TextStyle _bodyStyle(String? family, {required double size, required FontWeight weight, required Color color, double? letterSpacing}) {
    if (family == null || family.isEmpty) {
      return GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);
    }
    return TextStyle(fontFamily: family, fontSize: size, fontWeight: weight, color: color, letterSpacing: letterSpacing);
  }
}
