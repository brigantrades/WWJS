import 'package:flutter_test/flutter_test.dart';
import 'package:wwjs/core/audio_source_candidates.dart';

void main() {
  test('tries m4a after an mp3 URL', () {
    final candidates = audioSourceCandidates(
      'https://example.com/prayer-audio/day_002.mp3',
    );

    expect(candidates.map((uri) => uri.toString()), [
      'https://example.com/prayer-audio/day_002.mp3',
      'https://example.com/prayer-audio/day_002.m4a',
    ]);
  });

  test('tries mp3 after an m4a URL and preserves the query', () {
    final candidates = audioSourceCandidates(
      'https://example.com/prayer-audio/day_002.m4a?token=abc',
    );

    expect(candidates.map((uri) => uri.toString()), [
      'https://example.com/prayer-audio/day_002.m4a?token=abc',
      'https://example.com/prayer-audio/day_002.mp3?token=abc',
    ]);
  });

  test('does not alter unsupported extensions', () {
    final candidates = audioSourceCandidates(
      'https://example.com/prayer-audio/day_002.wav',
    );

    expect(candidates.map((uri) => uri.toString()), [
      'https://example.com/prayer-audio/day_002.wav',
    ]);
  });
}
