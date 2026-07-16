import 'package:flutter/widgets.dart';

abstract final class AppLayout {
  // iPad-class window widths start above Flutter's common 600px test surface.
  // Keeping this threshold higher also guarantees existing phone layouts are
  // not selected into the tablet composition.
  static const tabletBreakpoint = 700.0;
  static const tabletContentWidth = 760.0;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;

  static double horizontalInset(
    BuildContext context, {
    required double phoneInset,
    double tabletContentWidth = AppLayout.tabletContentWidth,
  }) {
    if (!isTablet(context)) return phoneInset;

    final centeredInset =
        (MediaQuery.sizeOf(context).width - tabletContentWidth) / 2;
    return centeredInset < phoneInset ? phoneInset : centeredInset;
  }
}
