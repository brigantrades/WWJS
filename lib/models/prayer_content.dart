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

  factory PrayerSection.fromJson(Map<String, dynamic> json) => PrayerSection(
    type: PrayerSectionType.values.byName(json['type'] as String),
    label: json['label'] as String,
    text: json['text'] as String,
    startsAt: Duration(milliseconds: json['starts_at_ms'] as int),
  );
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
    required this.audioUrl,
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
  final String audioUrl;
  final Duration estimatedDuration;
  final List<PrayerSection> sections;
  final bool hasProductionAudio;

  factory PrayerContent.fromJson(Map<String, dynamic> json) => PrayerContent(
    day: json['day'] as int,
    title: json['title'] as String,
    scriptureReference: json['scripture_reference'] as String,
    scriptureText: json['scripture_text'] as String,
    preparationText: json['preparation_text'] as String,
    reflectionText: json['reflection_text'] as String,
    responsePrayer: json['response_prayer'] as String,
    closingText: json['closing_text'] as String,
    audioUrl: json['audio_url'] as String,
    estimatedDuration: Duration(milliseconds: json['duration_ms'] as int),
    hasProductionAudio: json['has_production_audio'] as bool? ?? true,
    sections: (json['sections'] as List<dynamic>)
        .map((item) => PrayerSection.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
  );

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
