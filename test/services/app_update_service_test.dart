import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wwjs/services/app_update_service.dart';

void main() {
  final update = AppUpdate(
    platform: 'android',
    latestBuild: 6,
    storeUrl: Uri.parse('market://details?id=com.wwjs.wwjs'),
  );

  test('returns an update when the remote build is newer', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(update),
      packageInfoLoader: () async => _packageInfo(build: '5'),
      platform: 'android',
    );

    expect(await service.availableUpdate(), update);
  });

  test('does not return an update for the current build', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(update),
      packageInfoLoader: () async => _packageInfo(build: '6'),
      platform: 'android',
    );

    expect(await service.availableUpdate(), isNull);
  });

  test('maybe later snoozes the same update for 24 hours', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 7, 12, 12);
    final service = AppUpdateService(
      repository: _FakeRepository(update),
      packageInfoLoader: () async => _packageInfo(build: '5'),
      platform: 'android',
      now: () => now,
    );

    await service.remindLater(update);

    expect(await service.availableUpdate(), isNull);
  });
}

PackageInfo _packageInfo({required String build}) => PackageInfo(
  appName: 'WWJS',
  packageName: 'com.wwjs.wwjs',
  version: '1.0.3',
  buildNumber: build,
);

class _FakeRepository implements AppUpdateRepository {
  const _FakeRepository(this.update);

  final AppUpdate? update;

  @override
  Future<AppUpdate?> fetchForPlatform(String platform) async => update;
}
