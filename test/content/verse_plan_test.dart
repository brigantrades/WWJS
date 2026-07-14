import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/data/prayers.dart';

import '../../tool/verse_plan_validator.dart';

void main() {
  final registryFile = File('content/verse_plan.json');

  test('verse plan has no duplicate or overlapping passages', () {
    final result = validateVersePlan(registryFile);

    expect(result.errors, isEmpty, reason: result.errors.join('\n'));
    expect(result.dayCount, greaterThanOrEqualTo(30));
  });

  test('every bundled prayer matches an existing registry entry', () {
    final registry =
        jsonDecode(registryFile.readAsStringSync()) as Map<String, dynamic>;
    final days = (registry['days'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final existingByDay = <int, Map<String, dynamic>>{
      for (final day in days.where((day) => day['status'] == 'existing'))
        day['day'] as int: day,
    };

    expect(
      existingByDay.keys,
      unorderedEquals(prayers.map((prayer) => prayer.day)),
    );

    for (final prayer in prayers) {
      final registryDay = existingByDay[prayer.day];
      expect(
        registryDay,
        isNotNull,
        reason: 'Day ${prayer.day} is missing from the registry.',
      );
      expect(
        _normalizeReference(registryDay!['scripture_reference'] as String),
        _normalizeReference(prayer.scriptureReference),
        reason:
            'Day ${prayer.day} has a different passage in the app and registry.',
      );
      expect(registryDay['title'], prayer.title);
    }
  });
}

String _normalizeReference(String reference) => reference
    .replaceAll(RegExp(r'[–—]'), '-')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();
