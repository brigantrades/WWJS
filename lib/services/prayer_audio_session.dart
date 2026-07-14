import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../core/audio_source_candidates.dart';
import '../models/prayer_content.dart';

class PrayerAudioSession {
  PrayerAudioSession({AudioPlayer? player}) : player = player ?? AudioPlayer();

  final AudioPlayer player;

  Future<void> _operation = Future.value();
  Future<Duration?>? _requestedPreparation;
  int? _requestedDay;
  int? _preparedDay;

  Future<Duration?> prepare(PrayerContent prayer) {
    if (_requestedDay == prayer.day && _requestedPreparation != null) {
      return _requestedPreparation!;
    }

    _requestedDay = prayer.day;
    final preparation = _operation.then((_) async {
      try {
        if (_preparedDay == prayer.day) return player.duration;

        final mediaItem = MediaItem(
          id: 'prayer-${prayer.day}',
          album: 'WWJS: What Would Jesus Say?',
          title: 'Day ${prayer.day}: ${prayer.title}',
          displaySubtitle: prayer.scriptureReference,
        );
        Object? lastError;
        StackTrace? lastStackTrace;

        for (final uri in audioSourceCandidates(prayer.audioUrl)) {
          try {
            final duration = await player.setAudioSource(
              AudioSource.uri(uri, tag: mediaItem),
            );
            _preparedDay = prayer.day;
            return duration;
          } catch (error, stackTrace) {
            lastError = error;
            lastStackTrace = stackTrace;
          }
        }

        Error.throwWithStackTrace(lastError!, lastStackTrace!);
      } catch (_) {
        if (_requestedDay == prayer.day) {
          _requestedDay = null;
          _requestedPreparation = null;
        }
        rethrow;
      }
    });
    _requestedPreparation = preparation;
    _operation = preparation.then<void>((_) {}, onError: (_, _) {});
    return preparation;
  }

  Future<void> dispose() => player.dispose();
}
