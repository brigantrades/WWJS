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
      androidUpdateInvoker: _noPlayUpdate,
    );

    expect(await service.availableUpdate(), update);
  });

  test('does not return an update for the current build', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(update),
      packageInfoLoader: () async => _packageInfo(build: '6'),
      platform: 'android',
      androidUpdateInvoker: _noPlayUpdate,
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
      androidUpdateInvoker: _noPlayUpdate,
    );

    await service.remindLater(update);

    expect(await service.availableUpdate(), isNull);
  });

  test('does not prompt again after opening the same update', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(update),
      packageInfoLoader: () async => _packageInfo(build: '5'),
      platform: 'android',
      androidUpdateInvoker: _noPlayUpdate,
    );

    await service.markUpdateOpened(update);

    expect(await service.availableUpdate(), isNull);
  });

  test('uses the Google Play update when one is available', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(null),
      packageInfoLoader: () async => _packageInfo(build: '6'),
      platform: 'android',
      androidUpdateInvoker: (method, arguments) async => {
        'updateAvailable': true,
        'availableVersionCode': 7,
      },
    );

    final result = await service.availableUpdate();

    expect(result?.latestBuild, 7);
    expect(
      result?.storeUrl.toString(),
      'https://play.google.com/store/apps/details?id=com.wwjs.wwjs',
    );
  });

  test('trusts Google Play when it reports an available update', () async {
    SharedPreferences.setMockInitialValues({});
    final service = AppUpdateService(
      repository: _FakeRepository(null),
      packageInfoLoader: () async => _packageInfo(build: '10'),
      platform: 'android',
      androidUpdateInvoker: (method, arguments) async => {
        'updateAvailable': true,
        'availableVersionCode': 10,
      },
    );

    expect(await service.availableUpdate(), isNotNull);
  });

  test(
    'opens the Play Store listing without starting an in-app flow',
    () async {
      var nativeInvocationCount = 0;
      Uri? launchedUrl;
      final service = AppUpdateService(
        repository: _FakeRepository(null),
        platform: 'android',
        androidUpdateInvoker: (method, arguments) async {
          nativeInvocationCount += 1;
          return null;
        },
        urlLauncher: (url) async {
          launchedUrl = url;
          return true;
        },
      );
      final playUpdate = AppUpdate(
        platform: 'android',
        latestBuild: 8,
        storeUrl: Uri.parse(
          'https://play.google.com/store/apps/details?id=com.wwjs.wwjs',
        ),
      );

      expect(await service.openUpdate(playUpdate), isTrue);
      expect(nativeInvocationCount, 0);
      expect(launchedUrl, playUpdate.storeUrl);
    },
  );
}

Future<Map<String, Object?>?> _noPlayUpdate(
  String method,
  Map<String, Object?>? arguments,
) async => null;

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
