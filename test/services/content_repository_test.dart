import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/data/prayers.dart';
import 'package:wwjs/models/prayer_content.dart';
import 'package:wwjs/services/content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'returns local content immediately and preserves refreshed content',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = LocalFirstContentRepository(
        remote: _ContentRepository([prayers.first]),
        fallback: _ContentRepository([prayers[1]]),
      );

      expect((await repository.fetchPublishedPrayers()).single.day, 2);
      expect((await repository.refreshPublishedPrayers()).single.day, 1);

      final restored = LocalFirstContentRepository(
        remote: _ContentRepository([prayers[2]]),
        fallback: _ContentRepository([prayers[1]]),
      );
      final cached = await restored.fetchPublishedPrayers();

      expect(cached.single.day, 1);
      expect(cached.single.toJson(), prayers.first.toJson());
    },
  );
}

class _ContentRepository implements ContentRepository {
  const _ContentRepository(this.prayers);

  final List<PrayerContent> prayers;

  @override
  Future<List<PrayerContent>> fetchPublishedPrayers() async => prayers;
}
