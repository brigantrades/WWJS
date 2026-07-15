import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/content_repository.dart';
import 'services/app_update_service.dart';
import 'services/prayer_audio_session.dart';
import 'services/subscription_service.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  const definedUrl = String.fromEnvironment('SUPABASE_URL');
  const definedKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  final supabaseUrl = definedUrl.isNotEmpty
      ? definedUrl
      : dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = definedKey.isNotEmpty
      ? definedKey
      : dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError('Set SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY in .env.');
  }
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentSession == null) {
    await supabase.auth.signInAnonymously();
  }
  final subscriptionService = SubscriptionService(supabase);
  await subscriptionService.initialize();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wwjs.wwjs.audio',
    androidNotificationChannelName: 'Prayer playback',
    androidNotificationOngoing: true,
  );
  final controller = AppController(
    contentRepository: SupabaseContentRepository(supabase),
    subscriptionService: subscriptionService,
    audioSession: PrayerAudioSession(),
  );
  await controller.initialize();
  final updateService = AppUpdateService(
    repository: SupabaseAppUpdateRepository(supabase),
  );
  runApp(WWJSApp(controller: controller, updateService: updateService));
}
