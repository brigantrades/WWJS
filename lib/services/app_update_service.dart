import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdate {
  const AppUpdate({
    required this.platform,
    required this.latestBuild,
    required this.storeUrl,
    this.nativeUpdateType,
  });

  final String platform;
  final int latestBuild;
  final Uri storeUrl;
  final String? nativeUpdateType;
}

abstract interface class AppUpdateRepository {
  Future<AppUpdate?> fetchForPlatform(String platform);
}

class SupabaseAppUpdateRepository implements AppUpdateRepository {
  const SupabaseAppUpdateRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUpdate?> fetchForPlatform(String platform) async {
    final row = await _client
        .from('app_update_config')
        .select('platform, latest_build, store_url, enabled')
        .eq('platform', platform)
        .maybeSingle();
    if (row == null || row['enabled'] != true) return null;

    return AppUpdate(
      platform: row['platform'] as String,
      latestBuild: row['latest_build'] as int,
      storeUrl: Uri.parse(row['store_url'] as String),
    );
  }
}

typedef PackageInfoLoader = Future<PackageInfo> Function();
typedef ExternalUrlLauncher = Future<bool> Function(Uri url);
typedef AndroidUpdateInvoker =
    Future<Map<String, Object?>?> Function(
      String method,
      Map<String, Object?>? arguments,
    );

class AppUpdateService {
  AppUpdateService({
    required AppUpdateRepository repository,
    PackageInfoLoader? packageInfoLoader,
    ExternalUrlLauncher? urlLauncher,
    AndroidUpdateInvoker? androidUpdateInvoker,
    String? platform,
    DateTime Function()? now,
  }) : _repository = repository,
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform,
       _urlLauncher = urlLauncher ?? _launchExternally,
       _androidUpdateInvoker = androidUpdateInvoker ?? _invokeAndroidUpdate,
       _platform = platform ?? _currentPlatform(),
       _now = now ?? DateTime.now;

  static const _snoozeDuration = Duration(hours: 24);
  static const _snoozedBuildKey = 'update_snoozed_build';
  static const _snoozedAtKey = 'update_snoozed_at';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.wwjs.wwjs';
  static const _androidUpdateChannel = MethodChannel('wwjs/app_update');

  final AppUpdateRepository _repository;
  final PackageInfoLoader _packageInfoLoader;
  final ExternalUrlLauncher _urlLauncher;
  final AndroidUpdateInvoker _androidUpdateInvoker;
  final String? _platform;
  final DateTime Function() _now;

  Future<AppUpdate?> availableUpdate() async {
    final platform = _platform;
    if (platform == null) return null;

    final packageInfo = await _packageInfoLoader();
    final currentBuild = int.tryParse(packageInfo.buildNumber);
    if (currentBuild == null) return null;

    AppUpdate? update;
    var suppliedByGooglePlay = false;
    if (platform == 'android') {
      update = await _androidPlayUpdate();
      suppliedByGooglePlay = update != null;
    }
    if (update == null) {
      try {
        update = await _repository.fetchForPlatform(platform);
      } catch (error, stackTrace) {
        debugPrint('App update fallback lookup failed: $error\n$stackTrace');
        return null;
      }
    }
    if (update == null) return null;
    if (!suppliedByGooglePlay && update.latestBuild <= currentBuild) {
      return null;
    }

    final preferences = await SharedPreferences.getInstance();
    final snoozedBuild = preferences.getInt(_snoozedBuildKey);
    final snoozedAtMillis = preferences.getInt(_snoozedAtKey);
    if (snoozedBuild == update.latestBuild && snoozedAtMillis != null) {
      final snoozedAt = DateTime.fromMillisecondsSinceEpoch(snoozedAtMillis);
      if (_now().difference(snoozedAt) < _snoozeDuration) return null;
    }

    return update;
  }

  Future<void> remindLater(AppUpdate update) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_snoozedBuildKey, update.latestBuild);
    await preferences.setInt(_snoozedAtKey, _now().millisecondsSinceEpoch);
  }

  Future<bool> openUpdate(AppUpdate update) async {
    final nativeUpdateType = update.nativeUpdateType;
    if (nativeUpdateType != null) {
      try {
        final result = await _androidUpdateInvoker('startUpdate', {
          'type': nativeUpdateType,
        });
        if (result?['started'] == true) return true;
      } catch (_) {
        // Fall back to the Play Store listing if the native flow cannot start.
      }
    }
    return _urlLauncher(update.storeUrl);
  }

  Future<bool> openConfiguredStore() async {
    final platform = _platform;
    if (platform == null) return false;
    final config = await _repository.fetchForPlatform(platform);
    if (config == null) return false;
    return _urlLauncher(config.storeUrl);
  }

  static String? _currentPlatform() => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => null,
  };

  static Future<bool> _launchExternally(Uri url) {
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<AppUpdate?> _androidPlayUpdate() async {
    try {
      final result = await _androidUpdateInvoker(
        'checkForUpdate',
        null,
      ).timeout(const Duration(seconds: 8));
      debugPrint('Google Play update response: $result');
      if (result?['updateAvailable'] != true) return null;
      final latestBuild = int.tryParse(
        result?['availableVersionCode']?.toString() ?? '',
      );
      if (latestBuild == null) return null;
      return AppUpdate(
        platform: 'android',
        latestBuild: latestBuild,
        storeUrl: Uri.parse(_playStoreUrl),
        nativeUpdateType: result?['recommendedType']?.toString() == 'immediate'
            ? 'immediate'
            : 'flexible',
      );
    } catch (error, stackTrace) {
      debugPrint('Google Play update lookup failed: $error\n$stackTrace');
      return null;
    }
  }

  static Future<Map<String, Object?>?> _invokeAndroidUpdate(
    String method,
    Map<String, Object?>? arguments,
  ) {
    return _androidUpdateChannel.invokeMapMethod<String, Object?>(
      method,
      arguments,
    );
  }
}
