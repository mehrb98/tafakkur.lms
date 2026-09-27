import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hero_colors.dart';

/// HeroUI radii: `--radius` is 8px, fields use 1.5x, cards use `rounded-3xl`,
/// buttons are pills.
class HeroRadius {
  static const double base = 8;
  static const double field = 12;
  static const double item = 12;
  static const double card = 24;
}

ThemeData buildHeroTheme(Brightness brightness) {
  final hero = brightness == Brightness.light ? HeroColors.light : HeroColors.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: hero.accent,
    onPrimary: hero.accentForeground,
    secondary: hero.defaultColor,
    onSecondary: hero.foreground,
    error: hero.danger,
    onError: hero.accentForeground,
    surface: hero.surface,
    onSurface: hero.foreground,
    onSurfaceVariant: hero.muted,
    outline: hero.border,
    outlineVariant: hero.separator,
    surfaceContainerLowest: hero.background,
    surfaceContainerLow: hero.background,
    surfaceContainer: hero.surface,
    surfaceContainerHigh: hero.surfaceSecondary,
    surfaceContainerHighest: hero.surfaceTertiary,
  );

  final baseText = brightness == Brightness.light ? Typography.blackMountainView : Typography.whiteMountainView;
  final textTheme = GoogleFonts.interTextTheme(baseText)
      .apply(bodyColor: hero.foreground, displayColor: hero.foreground);

  const pill = StadiumBorder();
  const buttonSize = Size(0, 40);
  final buttonText = textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 14);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: hero.background,
    textTheme: textTheme,
    extensions: [hero],
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: hero.separator, thickness: 1, space: 1),
    cardTheme: CardThemeData(
      color: hero.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HeroRadius.card)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: hero.accent,
        foregroundColor: hero.accentForeground,
        minimumSize: buttonSize,
        shape: pill,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: hero.foreground,
        minimumSize: buttonSize,
        shape: pill,
        side: BorderSide(color: hero.border),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: hero.accent, shape: pill, textStyle: buttonText),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: hero.foreground, shape: pill),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: hero.field,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: TextStyle(color: hero.muted, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(HeroRadius.field), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HeroRadius.field),
        borderSide: brightness == Brightness.light
            ? BorderSide(color: hero.border.withValues(alpha: 0.6))
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HeroRadius.field),
        borderSide: BorderSide(color: hero.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(HeroRadius.field),
        borderSide: BorderSide(color: hero.danger),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: hero.border, width: 1.5),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: hero.surface,
        borderRadius: BorderRadius.circular(HeroRadius.item),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      textStyle: TextStyle(color: hero.foreground, fontSize: 12),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: hero.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HeroRadius.field + 4)),
    ),
    drawerTheme: DrawerThemeData(backgroundColor: hero.surface, width: 288),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: hero.accent, linearTrackColor: hero.defaultColor),
  );
}
