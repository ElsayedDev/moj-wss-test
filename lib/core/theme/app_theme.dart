import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color _jade = Color(0xFF0C8F71);
  static const Color _lightBackground = Color(0xFFF4F7F5);
  static const Color _lightSurface = Color(0xFFEAF1EE);
  static const Color _lightText = Color(0xFF15201D);
  static const Color _darkBackground = Color(0xFF111816);
  static const Color _darkSurface = Color(0xFF1A2521);
  static const Color _darkText = Color(0xFFE7EFEC);
  static const Color _error = Color(0xFFBA1A1A);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _jade,
      brightness: Brightness.light,
      primary: _jade,
      surface: _lightSurface,
      error: _error,
    ).copyWith(surface: _lightSurface, onSurface: _lightText);

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: _lightBackground,
      extensions: const [
        GlassColors(
          pageGradientStart: Color(0xFFF8FBFA),
          pageGradientEnd: Color(0xFFDCE8E3),
          panelFill: Color(0xCCF9FCFA),
          panelBorder: Color(0x99B7C8C1),
          subtleFill: Color(0x99E2EEE9),
        ),
      ],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _jade,
      brightness: Brightness.dark,
      primary: const Color(0xFF37C6A5),
      surface: _darkSurface,
      error: const Color(0xFFFFB4AB),
    ).copyWith(surface: _darkSurface, onSurface: _darkText);

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: _darkBackground,
      extensions: const [
        GlassColors(
          pageGradientStart: Color(0xFF101714),
          pageGradientEnd: Color(0xFF20362F),
          panelFill: Color(0xB31D2925),
          panelBorder: Color(0x665A776D),
          subtleFill: Color(0x662D4039),
        ),
      ],
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: null,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

@immutable
class GlassColors extends ThemeExtension<GlassColors> {
  const GlassColors({
    required this.pageGradientStart,
    required this.pageGradientEnd,
    required this.panelFill,
    required this.panelBorder,
    required this.subtleFill,
  });

  final Color pageGradientStart;
  final Color pageGradientEnd;
  final Color panelFill;
  final Color panelBorder;
  final Color subtleFill;

  @override
  GlassColors copyWith({
    Color? pageGradientStart,
    Color? pageGradientEnd,
    Color? panelFill,
    Color? panelBorder,
    Color? subtleFill,
  }) {
    return GlassColors(
      pageGradientStart: pageGradientStart ?? this.pageGradientStart,
      pageGradientEnd: pageGradientEnd ?? this.pageGradientEnd,
      panelFill: panelFill ?? this.panelFill,
      panelBorder: panelBorder ?? this.panelBorder,
      subtleFill: subtleFill ?? this.subtleFill,
    );
  }

  @override
  GlassColors lerp(ThemeExtension<GlassColors>? other, double t) {
    if (other is! GlassColors) {
      return this;
    }
    return GlassColors(
      pageGradientStart: Color.lerp(
        pageGradientStart,
        other.pageGradientStart,
        t,
      )!,
      pageGradientEnd: Color.lerp(pageGradientEnd, other.pageGradientEnd, t)!,
      panelFill: Color.lerp(panelFill, other.panelFill, t)!,
      panelBorder: Color.lerp(panelBorder, other.panelBorder, t)!,
      subtleFill: Color.lerp(subtleFill, other.subtleFill, t)!,
    );
  }
}
