import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'state/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.wwjs.wwjs.audio',
    androidNotificationChannelName: 'Prayer playback',
    androidNotificationOngoing: true,
  );
  final controller = AppController();
  await controller.initialize();
  runApp(WWJSApp(controller: controller));
}
