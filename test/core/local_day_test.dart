import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/local_day.dart';

void main() {
  test('calendar-day differences are not shortened by daylight saving', () {
    expect(
      calendarDayDifference(DateTime(2026, 1, 1), DateTime(2026, 4, 1)),
      90,
    );
  });
}
