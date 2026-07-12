import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdate {
  const AppUpdate({
    required this.platform,
    required this.latestBuild,
    required this.storeUrl,
  });

  final String platform;
  final int latestBuild;
  final Uri storeUrl;
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

class AppUpdateService {
  AppUpdateService({
    required AppUpdateRepository repository,
    PackageInfoLoader? packageInfoLoader,
    ExternalUrlLauncher? urlLauncher,
    String? platform,
    DateTime Function()? now,
  }) : _repository = repository,
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform,
       _urlLauncher = urlLauncher ?? _launchExternally,
       _platform = platform ?? _currentPlatform(),
       _now = now ?? DateTime.now;

  static const _snoozeDuration = Duration(hours: 24);
  static const _snoozedBuildKey = 'update_snoozed_build';
  static const _snoozedAtKey = 'update_snoozed_at';

  final AppUpdateRepository _repository;
  final PackageInfoLoader _packageInfoLoader;
  final ExternalUrlLauncher _urlLauncher;
  final String? _platform;
  final DateTime Function() _now;

  Future<AppUpdate?> availableUpdate() async {
    final platform = _platform;
    if (platform == null) return null;

    final config = await _repository.fetchForPlatform(platform);
    if (config == null) return null;

    final packageInfo = await _packageInfoLoader();
    final currentBuild = int.tryParse(packageInfo.buildNumber);
    if (currentBuild == null || config.latestBuild <= currentBuild) return null;

    final preferences = await SharedPreferences.getInstance();
    final snoozedBuild = preferences.getInt(_snoozedBuildKey);
    final snoozedAtMillis = preferences.getInt(_snoozedAtKey);
    if (snoozedBuild == config.latestBuild && snoozedAtMillis != null) {
      final snoozedAt = DateTime.fromMillisecondsSinceEpoch(snoozedAtMillis);
      if (_now().difference(snoozedAt) < _snoozeDuration) return null;
    }

    return config;
  }

  Future<void> remindLater(AppUpdate update) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_snoozedBuildKey, update.latestBuild);
    await preferences.setInt(_snoozedAtKey, _now().millisecondsSinceEpoch);
  }

  Future<bool> openUpdate(AppUpdate update) => _urlLauncher(update.storeUrl);

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
}
