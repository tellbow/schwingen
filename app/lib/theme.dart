import 'package:flutter/material.dart';

const _light = ColorScheme.light(
  primary: Color(0xFF362500),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDEA7),
  onPrimaryContainer: Color(0xFF362500),
  secondary: Color(0xFF6B6258),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFE0D9D0),
  onSecondaryContainer: Color(0xFF5C5448),
  tertiary: Color(0xFF244515),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC5EFAD),
  onTertiaryContainer: Color(0xFF2D4F1E),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF93000A),
  surface: Color(0xFFF9F7F4),
  onSurface: Color(0xFF0B1C30),
  onSurfaceVariant: Color(0xFF7F7669),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF2EDE8),
  surfaceContainer: Color(0xFFEDE6DE),
  surfaceContainerHigh: Color(0xFFE6DDD3),
  surfaceContainerHighest: Color(0xFFDED4C8),
  outline: Color(0xFF7F7669),
  outlineVariant: Color(0xFFD0C5B6),
  surfaceTint: Color(0xFF735B2D),
);

const _dark = ColorScheme.dark(
  primary: Color(0xFFD4A96A),
  onPrimary: Color(0xFF1A1000),
  primaryContainer: Color(0xFF3D2A06),
  onPrimaryContainer: Color(0xFFD4A96A),
  secondary: Color(0xFF6A7D94),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF2A3347),
  onSecondaryContainer: Color(0xFFA8B8CC),
  tertiary: Color(0xFFA8E68E),
  onTertiary: Color(0xFF0D2E02),
  tertiaryContainer: Color(0xFF163D08),
  onTertiaryContainer: Color(0xFFA8E68E),
  error: Color(0xFFFF7070),
  onError: Color(0xFF1A0000),
  errorContainer: Color(0xFF3F0010),
  onErrorContainer: Color(0xFFFFB3B3),
  surface: Color(0xFF0D1117),
  onSurface: Color(0xFFE6E1D8),
  onSurfaceVariant: Color(0xFF7A7260),
  surfaceContainerLowest: Color(0xFF1E242C),
  surfaceContainerLow: Color(0xFF131821),
  surfaceContainer: Color(0xFF252D38),
  surfaceContainerHigh: Color(0xFF2A3240),
  surfaceContainerHighest: Color(0xFF303848),
  outline: Color(0xFF7A7260),
  outlineVariant: Color(0xFF30363D),
  surfaceTint: Color(0xFFD4A96A),
);

ThemeData tellbowTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark ? _dark : _light;
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
  );
}

Color resultColor(ColorScheme scheme, String result) => switch (result) {
  '+' => scheme.tertiary,
  'o' => scheme.error,
  _ => scheme.onSurfaceVariant,
};
