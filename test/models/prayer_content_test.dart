import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/data/prayers.dart';
import 'package:wwjs/models/prayer_content.dart';

void main() {
  test('read-along transcript uses the complete prayer copy', () {
    final prayer = prayers.first;

    expect(
      prayer.transcriptFor(PrayerSectionType.scripture),
      prayer.scriptureText,
    );
    expect(
      prayer.transcriptFor(PrayerSectionType.reflection),
      prayer.reflectionText,
    );
    expect(
      prayer.transcriptFor(PrayerSectionType.response),
      prayer.responsePrayer,
    );
  });
}
