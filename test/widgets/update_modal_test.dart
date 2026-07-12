import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/app_theme.dart';
import 'package:wwjs/widgets/update_modal.dart';

void main() {
  testWidgets('shows the update prompt without a version number', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () => showUpdateModal(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Your Journey Continues'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);
    expect(find.textContaining(RegExp(r'v?\d+\.\d+')), findsNothing);
  });

  testWidgets('returns the selected action', (tester) async {
    UpdateModalAction? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => FilledButton(
            onPressed: () async => result = await showUpdateModal(context),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();

    expect(result, UpdateModalAction.update);
  });
}
