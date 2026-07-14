import 'dart:convert';
import 'dart:io';

class VersePlanValidationResult {
  const VersePlanValidationResult({
    required this.errors,
    required this.dayCount,
    required this.verseCount,
    required this.statusCounts,
    required this.toneCounts,
    required this.genreCounts,
  });

  final List<String> errors;
  final int dayCount;
  final int verseCount;
  final Map<String, int> statusCounts;
  final Map<String, int> toneCounts;
  final Map<String, int> genreCounts;

  bool get isValid => errors.isEmpty;
}

VersePlanValidationResult validateVersePlan(File file) {
  final errors = <String>[];
  final statusCounts = <String, int>{};
  final toneCounts = <String, int>{};
  final genreCounts = <String, int>{};
  final seenDays = <int, int>{};
  final seenVerses = <String, int>{};

  dynamic decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on Object catch (error) {
    return VersePlanValidationResult(
      errors: ['Could not parse ${file.path}: $error'],
      dayCount: 0,
      verseCount: 0,
      statusCounts: statusCounts,
      toneCounts: toneCounts,
      genreCounts: genreCounts,
    );
  }

  if (decoded is! Map<String, dynamic>) {
    errors.add('The registry root must be a JSON object.');
    return VersePlanValidationResult(
      errors: errors,
      dayCount: 0,
      verseCount: 0,
      statusCounts: statusCounts,
      toneCounts: toneCounts,
      genreCounts: genreCounts,
    );
  }

  if (decoded['schema_version'] != 1) {
    errors.add('schema_version must be 1.');
  }

  final rawDays = decoded['days'];
  if (rawDays is! List<dynamic> || rawDays.isEmpty) {
    errors.add('days must be a non-empty array.');
    return VersePlanValidationResult(
      errors: errors,
      dayCount: 0,
      verseCount: 0,
      statusCounts: statusCounts,
      toneCounts: toneCounts,
      genreCounts: genreCounts,
    );
  }

  const requiredTextFields = <String>[
    'status',
    'title',
    'scripture_reference',
    'translation',
    'genre',
    'arc',
    'human_question',
    'emotional_posture',
    'tone',
    'relationship_to_previous',
    'carry_forward',
  ];
  const allowedStatuses = <String>{
    'planned',
    'approved',
    'recorded',
    'published',
    'existing',
  };
  const allowedTones = <String>{
    'hard-times',
    'balanced',
    'uplifting',
    'positive',
    'practical',
  };
  final verseIdPattern = RegExp(r'^[1-3]?[A-Za-z]+\.[0-9]+\.[0-9]+$');

  for (var index = 0; index < rawDays.length; index += 1) {
    final rawDay = rawDays[index];
    if (rawDay is! Map<String, dynamic>) {
      errors.add('days[$index] must be an object.');
      continue;
    }

    final day = rawDay['day'];
    if (day is! int || day <= 0) {
      errors.add('days[$index].day must be a positive integer.');
      continue;
    }

    final previousDayIndex = seenDays[day];
    if (previousDayIndex != null) {
      errors.add(
        'Day $day is duplicated at indexes $previousDayIndex and $index.',
      );
    } else {
      seenDays[day] = index;
    }

    for (final field in requiredTextFields) {
      final value = rawDay[field];
      if (value is! String || value.trim().isEmpty) {
        errors.add('Day $day must have a non-empty $field.');
      }
    }

    final status = rawDay['status'];
    if (status is String) {
      statusCounts.update(status, (count) => count + 1, ifAbsent: () => 1);
      if (!allowedStatuses.contains(status)) {
        errors.add('Day $day has unsupported status "$status".');
      }
    }

    final tone = rawDay['tone'];
    if (tone is String) {
      toneCounts.update(tone, (count) => count + 1, ifAbsent: () => 1);
      if (!allowedTones.contains(tone)) {
        errors.add('Day $day has unsupported tone "$tone".');
      }
    }

    final genre = rawDay['genre'];
    if (genre is String) {
      genreCounts.update(genre, (count) => count + 1, ifAbsent: () => 1);
    }

    final keyImages = rawDay['key_images'];
    if (keyImages is! List<dynamic> ||
        keyImages.isEmpty ||
        keyImages.any((image) => image is! String || image.trim().isEmpty)) {
      errors.add('Day $day must have at least one non-empty key image.');
    }

    final verseIds = rawDay['verse_ids'];
    if (verseIds is! List<dynamic> || verseIds.isEmpty) {
      errors.add('Day $day must have at least one verse_id.');
      continue;
    }

    for (final rawVerseId in verseIds) {
      if (rawVerseId is! String || !verseIdPattern.hasMatch(rawVerseId)) {
        errors.add('Day $day has invalid verse_id "$rawVerseId".');
        continue;
      }

      final previousDay = seenVerses[rawVerseId];
      if (previousDay != null) {
        errors.add('$rawVerseId overlaps days $previousDay and $day.');
      } else {
        seenVerses[rawVerseId] = day;
      }
    }
  }

  final sortedDays = seenDays.keys.toList()..sort();
  for (var index = 0; index < sortedDays.length; index += 1) {
    final expectedDay = index + 1;
    if (sortedDays[index] != expectedDay) {
      errors.add(
        'The plan must be sequential: expected day $expectedDay but found day ${sortedDays[index]}.',
      );
      break;
    }
  }

  return VersePlanValidationResult(
    errors: errors,
    dayCount: rawDays.length,
    verseCount: seenVerses.length,
    statusCounts: statusCounts,
    toneCounts: toneCounts,
    genreCounts: genreCounts,
  );
}

void main(List<String> arguments) {
  final path = arguments.isEmpty ? 'content/verse_plan.json' : arguments.first;
  final result = validateVersePlan(File(path));

  if (!result.isValid) {
    stderr.writeln('Verse plan validation failed:');
    for (final error in result.errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Verse plan valid: ${result.dayCount} days, ${result.verseCount} unique verses.',
  );
  stdout.writeln('Statuses: ${result.statusCounts}');
  stdout.writeln('Tones: ${result.toneCounts}');
  stdout.writeln('Genres: ${result.genreCounts}');
}
