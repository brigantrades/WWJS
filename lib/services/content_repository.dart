import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/prayers.dart' as fixtures;
import '../models/prayer_content.dart';

abstract interface class ContentRepository {
  Future<List<PrayerContent>> fetchPublishedPrayers();
}

class SupabaseContentRepository implements ContentRepository {
  const SupabaseContentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async {
    final rows = await _client
        .from('prayer_days')
        .select()
        .eq('is_published', true)
        .order('day');
    return rows
        .map((row) {
          final json = Map<String, dynamic>.from(row);
          json['audio_url'] = _client.storage
              .from('prayer-audio')
              .getPublicUrl(json['audio_path'] as String);
          return PrayerContent.fromJson(json);
        })
        .toList(growable: false);
  }
}

/// Test-only default. Production explicitly injects [SupabaseContentRepository].
class BundledContentRepository implements ContentRepository {
  const BundledContentRepository();

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async => fixtures.prayers;
}
