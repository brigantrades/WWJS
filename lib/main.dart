import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/content_repository.dart';
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
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wwjs.wwjs.audio',
    androidNotificationChannelName: 'Prayer playback',
    androidNotificationOngoing: true,
  );
  final controller = AppController(
    contentRepository: SupabaseContentRepository(Supabase.instance.client),
  );
  await controller.initialize();
  runApp(WWJSApp(controller: controller));
}
