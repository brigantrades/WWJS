import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/local_day.dart';

void main() {
  group('calculateUnlockedDay', () {
    test('starts at day one and advances by local calendar day', () {
      final start = DateTime(2026, 7, 11, 23, 55);
      expect(
        calculateUnlockedDay(
          startDate: start,
          today: DateTime(2026, 7, 11, 23, 59),
          previousHighest: 1,
          contentCount: 30,
        ),
        1,
      );
      expect(
        calculateUnlockedDay(
          startDate: start,
          today: DateTime(2026, 7, 12, 0, 1),
          previousHighest: 1,
          contentCount: 30,
        ),
        2,
      );
    });

    test('does not lose progress when the local clock moves backward', () {
      expect(
        calculateUnlockedDay(
          startDate: DateTime(2026, 7, 10),
          today: DateTime(2026, 7, 9),
          previousHighest: 3,
          contentCount: 30,
        ),
        3,
      );
    });

    test('never unlocks beyond bundled content', () {
      expect(
        calculateUnlockedDay(
          startDate: DateTime(2025, 1, 1),
          today: DateTime(2026, 7, 11),
          previousHighest: 1,
          contentCount: 3,
        ),
        3,
      );
    });
  });
}
