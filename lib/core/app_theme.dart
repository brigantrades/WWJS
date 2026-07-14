import 'package:flutter/material.dart';

abstract final class AppColors {
  static const warmBackground = Color(0xFFF7F4ED);
  static const playerIvory = Color(0xFFF7F2E8);
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

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.appBackground,
    required this.elevatedSurface,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.subtleBorder,
    required this.selectedSurface,
    required this.navigationBackground,
    required this.controlSurface,
    required this.unselectedText,
    required this.scriptureText,
    required this.interactiveForeground,
    required this.selectionOutline,
    required this.completionSurface,
    required this.completionForeground,
    required this.shadow,
    required this.tileText,
  });

  static const light = AppSemanticColors(
    appBackground: AppColors.warmBackground,
    elevatedSurface: AppColors.warmWhite,
    primaryText: AppColors.charcoal,
    secondaryText: AppColors.charcoal,
    accent: AppColors.sage,
    subtleBorder: Colors.transparent,
    selectedSurface: AppColors.warmWhite,
    navigationBackground: AppColors.warmWhite,
    controlSurface: Color(0x21758675),
    unselectedText: Color(0x9E24302C),
    scriptureText: AppColors.sage,
    interactiveForeground: AppColors.forest,
    selectionOutline: Colors.transparent,
    completionSurface: AppColors.sage,
    completionForeground: Colors.white,
    shadow: Color(0x1F263D35),
    tileText: AppColors.sage,
  );

  static const dark = AppSemanticColors(
    appBackground: Color(0xFF17241F),
    elevatedSurface: Color(0xFF213129),
    primaryText: Color(0xFFF4EAD6),
    secondaryText: Color(0xFFC6C2B5),
    accent: Color(0xFFB8A66F),
    subtleBorder: Color(0xFF465D51),
    selectedSurface: Color(0xFF314437),
    navigationBackground: Color(0xFF0C1714),
    controlSurface: Color(0xFF293B34),
    unselectedText: Color(0xFF94A18B),
    scriptureText: Color(0xFF8FA07D),
    interactiveForeground: Color(0xFFF2E4C8),
    selectionOutline: Color(0xFFA88F52),
    completionSurface: Color(0xFF5F7854),
    completionForeground: Color(0xFFF2E4C8),
    shadow: Color(0x59000000),
    tileText: Color(0xFFF2E4C8),
  );

  static AppSemanticColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppSemanticColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  final Color appBackground;
  final Color elevatedSurface;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color subtleBorder;
  final Color selectedSurface;
  final Color navigationBackground;
  final Color controlSurface;
  final Color unselectedText;
  final Color scriptureText;
  final Color interactiveForeground;
  final Color selectionOutline;
  final Color completionSurface;
  final Color completionForeground;
  final Color shadow;
  final Color tileText;

  @override
  AppSemanticColors copyWith({
    Color? appBackground,
    Color? elevatedSurface,
    Color? primaryText,
    Color? secondaryText,
    Color? accent,
    Color? subtleBorder,
    Color? selectedSurface,
    Color? navigationBackground,
    Color? controlSurface,
    Color? unselectedText,
    Color? scriptureText,
    Color? interactiveForeground,
    Color? selectionOutline,
    Color? completionSurface,
    Color? completionForeground,
    Color? shadow,
    Color? tileText,
  }) {
    return AppSemanticColors(
      appBackground: appBackground ?? this.appBackground,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      accent: accent ?? this.accent,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      navigationBackground: navigationBackground ?? this.navigationBackground,
      controlSurface: controlSurface ?? this.controlSurface,
      unselectedText: unselectedText ?? this.unselectedText,
      scriptureText: scriptureText ?? this.scriptureText,
      interactiveForeground:
          interactiveForeground ?? this.interactiveForeground,
      selectionOutline: selectionOutline ?? this.selectionOutline,
      completionSurface: completionSurface ?? this.completionSurface,
      completionForeground: completionForeground ?? this.completionForeground,
      shadow: shadow ?? this.shadow,
      tileText: tileText ?? this.tileText,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      navigationBackground: Color.lerp(
        navigationBackground,
        other.navigationBackground,
        t,
      )!,
      controlSurface: Color.lerp(controlSurface, other.controlSurface, t)!,
      unselectedText: Color.lerp(unselectedText, other.unselectedText, t)!,
      scriptureText: Color.lerp(scriptureText, other.scriptureText, t)!,
      interactiveForeground: Color.lerp(
        interactiveForeground,
        other.interactiveForeground,
        t,
      )!,
      selectionOutline: Color.lerp(
        selectionOutline,
        other.selectionOutline,
        t,
      )!,
      completionSurface: Color.lerp(
        completionSurface,
        other.completionSurface,
        t,
      )!,
      completionForeground: Color.lerp(
        completionForeground,
        other.completionForeground,
        t,
      )!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      tileText: Color.lerp(tileText, other.tileText, t)!,
    );
  }
}

ThemeData buildAppTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final semantic = dark ? AppSemanticColors.dark : AppSemanticColors.light;
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
    scaffoldBackgroundColor: semantic.appBackground,
    dividerColor: dark ? Colors.white24 : AppColors.divider,
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    extensions: [semantic],
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
      color: semantic.elevatedSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: dark ? 88 : null,
      backgroundColor: semantic.navigationBackground,
      surfaceTintColor: Colors.transparent,
      indicatorColor: dark
          ? semantic.selectedSurface
          : AppColors.sage.withValues(alpha: .18),
      indicatorShape: StadiumBorder(
        side: BorderSide(color: semantic.selectionOutline),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: semantic.interactiveForeground,
            size: dark ? 28 : null,
          );
        }
        return IconThemeData(
          color: semantic.secondaryText,
          size: dark ? 28 : null,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? semantic.interactiveForeground
              : semantic.secondaryText,
          fontSize: dark ? 13 : 12,
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
