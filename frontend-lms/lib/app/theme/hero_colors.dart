import 'package:flutter/material.dart';

/// HeroUI v3 default theme tokens, converted from the OKLCH values in
/// `@heroui/styles/themes/default/variables.css` so the Flutter app matches
/// the web dashboard.
@immutable
class HeroColors extends ThemeExtension<HeroColors> {
  const HeroColors({
    required this.background,
    required this.foreground,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.muted,
    required this.defaultColor,
    required this.border,
    required this.separator,
    required this.field,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color background;
  final Color foreground;
  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color muted;
  final Color defaultColor;
  final Color border;
  final Color separator;
  final Color field;
  final Color accent;
  final Color accentForeground;
  final Color success;
  final Color warning;
  final Color danger;

  static const light = HeroColors(
    background: Color(0xFFF5F5F5),
    foreground: Color(0xFF18181B),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFEFEFF0),
    surfaceTertiary: Color(0xFFEAEAEB),
    muted: Color(0xFF71717A),
    defaultColor: Color(0xFFEBEBEC),
    border: Color(0xFFDEDEE0),
    separator: Color(0xFFE4E4E7),
    field: Color(0xFFFFFFFF),
    accent: Color(0xFF0485F7),
    accentForeground: Color(0xFFFCFCFC),
    success: Color(0xFF17C964),
    warning: Color(0xFFF5A524),
    danger: Color(0xFFFF383C),
  );

  static const dark = HeroColors(
    background: Color(0xFF060607),
    foreground: Color(0xFFFCFCFC),
    surface: Color(0xFF18181B),
    surfaceSecondary: Color(0xFF232325),
    surfaceTertiary: Color(0xFF262728),
    muted: Color(0xFF9F9FA9),
    defaultColor: Color(0xFF27272A),
    border: Color(0xFF28282C),
    separator: Color(0xFF212124),
    field: Color(0xFF18181B),
    accent: Color(0xFF0485F7),
    accentForeground: Color(0xFFFCFCFC),
    success: Color(0xFF17C964),
    warning: Color(0xFFF7B750),
    danger: Color(0xFFDB3B3E),
  );

  /// `--*-soft`: the tone at 15% over the surface, used for chips and icon tiles.
  Color soft(Color tone) => Color.alphaBlend(tone.withValues(alpha: 0.15), surface);

  /// `--*-soft-foreground`: readable text on a soft background.
  Color softForeground(Color tone) => Color.lerp(tone, foreground, 0.3)!;

  @override
  HeroColors copyWith({
    Color? background,
    Color? foreground,
    Color? surface,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? muted,
    Color? defaultColor,
    Color? border,
    Color? separator,
    Color? field,
    Color? accent,
    Color? accentForeground,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return HeroColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      muted: muted ?? this.muted,
      defaultColor: defaultColor ?? this.defaultColor,
      border: border ?? this.border,
      separator: separator ?? this.separator,
      field: field ?? this.field,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  HeroColors lerp(HeroColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return HeroColors(
      background: l(background, other.background),
      foreground: l(foreground, other.foreground),
      surface: l(surface, other.surface),
      surfaceSecondary: l(surfaceSecondary, other.surfaceSecondary),
      surfaceTertiary: l(surfaceTertiary, other.surfaceTertiary),
      muted: l(muted, other.muted),
      defaultColor: l(defaultColor, other.defaultColor),
      border: l(border, other.border),
      separator: l(separator, other.separator),
      field: l(field, other.field),
      accent: l(accent, other.accent),
      accentForeground: l(accentForeground, other.accentForeground),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      danger: l(danger, other.danger),
    );
  }
}

extension HeroColorsContext on BuildContext {
  HeroColors get hero => Theme.of(this).extension<HeroColors>()!;
}
