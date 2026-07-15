import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/prayers.dart' as fixtures;
import '../models/prayer_content.dart';

abstract interface class ContentRepository {
  Future<List<PrayerContent>> fetchPublishedPrayers();
}

abstract interface class RefreshableContentRepository
    implements ContentRepository {
  Future<List<PrayerContent>> refreshPublishedPrayers();
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

class LocalFirstContentRepository implements RefreshableContentRepository {
  const LocalFirstContentRepository({
    required this.remote,
    this.fallback = const BundledContentRepository(),
  });

  static const _cacheKey = 'published_prayers_cache_v1';

  final ContentRepository remote;
  final ContentRepository fallback;

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getString(_cacheKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as List<dynamic>;
        final prayers = decoded
            .map(
              (item) => PrayerContent.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false);
        if (prayers.isNotEmpty) return prayers;
      } catch (_) {
        await preferences.remove(_cacheKey);
      }
    }
    return fallback.fetchPublishedPrayers();
  }

  @override
  Future<List<PrayerContent>> refreshPublishedPrayers() async {
    final prayers = await remote.fetchPublishedPrayers();
    if (prayers.isEmpty) {
      throw StateError('No published prayer days were returned by Supabase.');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cacheKey,
      jsonEncode(prayers.map((prayer) => prayer.toJson()).toList()),
    );
    return prayers;
  }
}

/// Bundled content used by tests and as the first-install offline fallback.
class BundledContentRepository implements ContentRepository {
  const BundledContentRepository();

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async => fixtures.prayers;
}
