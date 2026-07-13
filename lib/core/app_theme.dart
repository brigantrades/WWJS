import 'package:flutter/material.dart';

abstract final class AppColors {
  static const warmBackground = Color(0xFFF7F4ED);
  static const dawnPeach = Color(0xFFE7B89B);
  static const sage = Color(0xFF758675);
  static const forest = Color(0xFF263D35);
  static const warmWhite = Color(0xFFFFFDF8);
  static const charcoal = Color(0xFF24302C);
  static const divider = Color(0xFFDDD8CE);
  static const disabled = Color(0xFFE7E3DA);
  static const darkBackground = Color(0xFF17241F);
  static const darkSurface = Color(0xFF213129);
  static const darkText = Color(0xFFF6F1E7);
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.sage,
    brightness: brightness,
    primary: dark ? const Color(0xFFA6B9A4) : AppColors.forest,
    surface: dark ? AppColors.darkSurface : AppColors.warmWhite,
    onSurface: dark ? AppColors.darkText : AppColors.charcoal,
  );

  final base = ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: dark
        ? AppColors.darkBackground
        : AppColors.warmBackground,
    dividerColor: dark ? Colors.white24 : AppColors.divider,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: TextStyle(
        fontFamily: 'serif',
        fontFamilyFallback: const ['Georgia', 'Times New Roman'],
        fontSize: 48,
        height: 1.05,
        color: scheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: 'serif',
        fontFamilyFallback: const ['Georgia', 'Times New Roman'],
        fontSize: 38,
        height: 1.1,
        color: scheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'serif',
        fontFamilyFallback: const ['Georgia', 'Times New Roman'],
        fontSize: 30,
        height: 1.2,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.5, color: scheme.onSurface),
      bodyMedium: TextStyle(fontSize: 15, height: 1.4, color: scheme.onSurface),
      labelLarge: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.sage,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: dark ? AppColors.darkSurface : AppColors.warmWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? AppColors.darkSurface : AppColors.warmWhite,
      indicatorColor: dark
          ? AppColors.sage
          : AppColors.sage.withValues(alpha: .18),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: dark ? Colors.white : AppColors.forest);
        }
        return IconThemeData(
          color: dark ? scheme.onSurfaceVariant : scheme.onSurface,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: dark && !states.contains(WidgetState.selected)
              ? scheme.onSurfaceVariant
              : scheme.onSurface,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.disabled,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.sage
            : AppColors.divider,
      ),
    ),
  );
}
