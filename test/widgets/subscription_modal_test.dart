import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/widgets/subscription_modal.dart';

void main() {
  group('shouldShowSubscriptionPaywall', () {
    test('shows after day 7 is completed for the first time', () {
      expect(
        shouldShowSubscriptionPaywall(
          completedDay: 7,
          wasAlreadyCompleted: false,
        ),
        isTrue,
      );
    });

    test('does not show for other days or a replay of day 7', () {
      expect(
        shouldShowSubscriptionPaywall(
          completedDay: 6,
          wasAlreadyCompleted: false,
        ),
        isFalse,
      );
      expect(
        shouldShowSubscriptionPaywall(
          completedDay: 7,
          wasAlreadyCompleted: true,
        ),
        isFalse,
      );
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'paywall keeps its branded design in ${brightness.name} theme',
      (tester) async {
        await _showPaywall(tester, brightness: brightness);

        final dialog = tester.widget<Dialog>(find.byType(Dialog));
        expect(dialog.backgroundColor, const Color(0xFF0C3028));
        expect(find.text('YOUR FIRST 7 DAYS'), findsOneWidget);
        final eyebrow = tester.widget<Text>(find.text('YOUR FIRST 7 DAYS'));
        expect(eyebrow.style?.color, const Color(0xFFF2C276));
        expect(eyebrow.style?.shadows, isNotEmpty);
        expect(find.text('Continue Your\nWalk with Jesus'), findsOneWidget);
        expect(
          find.text('“ Remain in me, as I also remain in you. ”'),
          findsOneWidget,
        );
        expect(find.text('A new prayer for every day'), findsOneWidget);
        expect(find.text('Keep meaningful words close'), findsOneWidget);
        expect(find.text('A peaceful, uninterrupted space'), findsOneWidget);
        expect(find.text('Best value'), findsOneWidget);
        expect(find.text('Continue My Journey'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('returns the selected monthly plan', (tester) async {
    SubscriptionPlan? result;
    await _showPaywall(tester, onResult: (value) => result = value);

    await tester.tap(find.text('Monthly'));
    await tester.pump();

    expect(
      find.text(r'$0.99 billed monthly   ·   Cancel anytime'),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue My Journey'));
    await tester.pumpAndSettle();

    expect(result, SubscriptionPlan.monthly);
  });

  testWidgets('fits a narrow phone without scrolling or overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _showPaywall(tester);

    expect(find.byType(Scrollable), findsNothing);
    expect(find.text('Continue My Journey'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _showPaywall(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  ValueChanged<SubscriptionPlan?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(brightness),
      home: Builder(
        builder: (context) => Scaffold(
          body: FilledButton(
            onPressed: () async {
              final result = await showSubscriptionModal(context);
              onResult?.call(result);
            },
            child: const Text('Show paywall'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Show paywall'));
  await tester.pumpAndSettle();
}
