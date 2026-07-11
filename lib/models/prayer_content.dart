enum PrayerSectionType { preparation, scripture, reflection, response, closing }

class PrayerSection {
  const PrayerSection({
    required this.type,
    required this.label,
    required this.text,
    required this.startsAt,
  });

  final PrayerSectionType type;
  final String label;
  final String text;
  final Duration startsAt;
}

class PrayerContent {
  const PrayerContent({
    required this.day,
    required this.title,
    required this.scriptureReference,
    required this.scriptureText,
    required this.preparationText,
    required this.reflectionText,
    required this.responsePrayer,
    required this.closingText,
    required this.audioAsset,
    required this.estimatedDuration,
    required this.sections,
    this.hasProductionAudio = false,
  });

  final int day;
  final String title;
  final String scriptureReference;
  final String scriptureText;
  final String preparationText;
  final String reflectionText;
  final String responsePrayer;
  final String closingText;
  final String audioAsset;
  final Duration estimatedDuration;
  final List<PrayerSection> sections;
  final bool hasProductionAudio;

  PrayerSection sectionAt(Duration position) {
    PrayerSection current = sections.first;
    for (final section in sections) {
      if (position >= section.startsAt) current = section;
    }
    return current;
  }

  String transcriptFor(PrayerSectionType type) => switch (type) {
    PrayerSectionType.preparation => preparationText,
    PrayerSectionType.scripture => scriptureText,
    PrayerSectionType.reflection => reflectionText,
    PrayerSectionType.response => responsePrayer,
    PrayerSectionType.closing => closingText,
  };
}
