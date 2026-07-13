import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/widgets/subscription_modal.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('paywall follows the ${brightness.name} theme', (tester) async {
      final theme = buildAppTheme(brightness);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showSubscriptionModal(context),
                child: const Text('Show paywall'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show paywall'));
      await tester.pumpAndSettle();

      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, theme.colorScheme.surface);

      final benefitIcon = tester.widget<Icon>(
        find.byIcon(Icons.wb_sunny_outlined),
      );
      expect(benefitIcon.color, theme.colorScheme.primary);

      final verse = tester.widget<Text>(
        find.text('“Give, and it will be given to you.”'),
      );
      expect(verse.style?.color, theme.colorScheme.primary);
    });
  }
}
