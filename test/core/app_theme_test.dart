import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/app_theme.dart';

void main() {
  test('dark navigation clearly distinguishes the selected destination', () {
    final navigationTheme = buildAppTheme(Brightness.dark).navigationBarTheme;
    const selected = {WidgetState.selected};
    const unselected = <WidgetState>{};

    expect(
      navigationTheme.indicatorColor,
      AppSemanticColors.dark.selectedSurface,
    );
    expect(
      navigationTheme.iconTheme!.resolve(selected)!.color,
      AppSemanticColors.dark.interactiveForeground,
    );
    expect(
      navigationTheme.iconTheme!.resolve(unselected)!.color,
      AppSemanticColors.dark.secondaryText,
    );
    expect(
      navigationTheme.labelTextStyle!.resolve(selected)!.fontWeight,
      FontWeight.w600,
    );
    expect(
      navigationTheme.labelTextStyle!.resolve(unselected)!.fontWeight,
      FontWeight.w400,
    );
  });
}
