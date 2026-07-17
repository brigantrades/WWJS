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

  test('scripture display always uses the complete registered passage', () {
    final source = prayers.first;
    final prayer = PrayerContent(
      day: 9,
      title: 'Hope While You Wait',
      scriptureReference: 'Psalm 42:11',
      scriptureText: 'Hope in God! For I shall still praise him.',
      preparationText: '',
      reflectionText: '',
      responsePrayer: '',
      closingText: '',
      audioUrl: source.audioUrl,
      estimatedDuration: const Duration(minutes: 3, seconds: 5),
      sections: const [
        PrayerSection(
          type: PrayerSectionType.scripture,
          label: 'Scripture',
          text: 'Shortened audio excerpt.',
          startsAt: Duration.zero,
        ),
      ],
    );

    expect(prayer.scriptureDisplayText, prayer.scriptureText);
  });

  test('empty section metadata still provides a safe playback section', () {
    final source = prayers.first;
    final prayer = PrayerContent(
      day: 9,
      title: 'Hope While You Wait',
      scriptureReference: 'Psalm 42:11',
      scriptureText: 'Hope in God! For I shall still praise him.',
      preparationText: '',
      reflectionText: '',
      responsePrayer: '',
      closingText: '',
      audioUrl: source.audioUrl,
      estimatedDuration: const Duration(minutes: 3, seconds: 5),
      sections: const [],
    );

    final section = prayer.sectionAt(Duration.zero);

    expect(section.type, PrayerSectionType.scripture);
    expect(section.text, prayer.scriptureText);
  });
}
