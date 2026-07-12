import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_update_service.dart';
import 'state/app_controller.dart';

class WWJSApp extends StatelessWidget {
  const WWJSApp({super.key, required this.controller, this.updateService});

  final AppController controller;
  final AppUpdateService? updateService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'WWJS — Pray with Jesus',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: controller.themeMode,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final systemScale = media.textScaler.scale(1);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  (systemScale * controller.textScale).clamp(.8, 2),
                ),
              ),
              child: child!,
            );
          },
          home: controller.onboardingComplete
              ? AppShell(controller: controller, updateService: updateService)
              : OnboardingScreen(controller: controller),
        );
      },
    );
  }
}
