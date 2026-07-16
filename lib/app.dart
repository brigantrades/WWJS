import 'dart:async';

import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_update_service.dart';
import 'state/app_controller.dart';

class WWJSApp extends StatefulWidget {
  const WWJSApp({super.key, required this.controller, this.updateService});

  final AppController controller;
  final AppUpdateService? updateService;

  @override
  State<WWJSApp> createState() => _WWJSAppState();
}

class _WWJSAppState extends State<WWJSApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(widget.controller.recordAppResumed());
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(widget.controller.recordAppBackgrounded());
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'WWJS: Pray With Jesus',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: widget.controller.themeMode,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final systemScale = media.textScaler.scale(1);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  (systemScale * widget.controller.textScale).clamp(.8, 2),
                ),
              ),
              child: child!,
            );
          },
          home: widget.controller.onboardingComplete
              ? AppShell(
                  controller: widget.controller,
                  updateService: widget.updateService,
                )
              : OnboardingScreen(controller: widget.controller),
        );
      },
    );
  }
}
