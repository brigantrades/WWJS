import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_layout.dart';
import '../core/app_theme.dart';
import '../services/app_update_service.dart';
import '../services/local_activity_store.dart';
import '../state/app_controller.dart';
import '../widgets/subscription_modal.dart';
import '../widgets/update_modal.dart';
import '../widgets/upgrade_prompt.dart';
import 'prayer_list_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller, this.updateService});

  final AppController controller;
  final AppUpdateService? updateService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  final List<int> _tabHistory = [];
  bool _checkingForUpdate = false;
  late int _handledTodayNavigationRequest;
  bool _returnToTodayScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handledTodayNavigationRequest = widget.controller.todayNavigationRequest;
    widget.controller.addListener(_handleControllerChanged);
    unawaited(widget.controller.recordScreenView(LocalActivityScreen.today));
    _scheduleUpdateCheck();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_handleControllerChanged);
    _handledTodayNavigationRequest = widget.controller.todayNavigationRequest;
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleControllerChanged() {
    final request = widget.controller.todayNavigationRequest;
    if (request == _handledTodayNavigationRequest) return;
    _handledTodayNavigationRequest = request;
    if (_returnToTodayScheduled) return;
    _returnToTodayScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _returnToTodayScheduled = false;
      if (mounted) _returnToToday();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _returnToToday() {
    final navigator = Navigator.of(context);
    final hadPushedRoute = navigator.canPop();
    final changedTab = _index != 0;
    if (changedTab || _tabHistory.isNotEmpty) {
      setState(() {
        _index = 0;
        _tabHistory.clear();
      });
    }
    if (hadPushedRoute) {
      navigator.popUntil((route) => route.isFirst);
    }
    if (changedTab || hadPushedRoute) {
      unawaited(widget.controller.recordScreenView(LocalActivityScreen.today));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _scheduleUpdateCheck();
        final subscriptionService = widget.controller.subscriptionService;
        if (subscriptionService != null) {
          unawaited(subscriptionService.syncPurchases());
        }
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _scheduleUpdateCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    if (_checkingForUpdate) return;
    final service = widget.updateService;
    if (service == null) return;

    _checkingForUpdate = true;
    try {
      final update = await service.availableUpdate();
      if (!mounted || update == null) return;

      final action = await showUpdateModal(context);
      if (!mounted) return;

      if (action == UpdateModalAction.update) {
        final opened = await service.openUpdate(update);
        if (opened) {
          await service.markUpdateOpened(update);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open the update page.')),
          );
        }
      } else if (action == UpdateModalAction.later) {
        await service.remindLater(update);
      }
    } catch (error, stackTrace) {
      // An update check must never prevent the app from opening.
      debugPrint('App update check failed: $error\n$stackTrace');
    } finally {
      _checkingForUpdate = false;
    }
  }

  void _selectTab(int value) {
    if (value == _index) return;
    setState(() {
      _tabHistory.add(_index);
      _index = value;
    });
    unawaited(widget.controller.recordScreenView(_screenFor(value)));
  }

  void _goBack() {
    setState(() {
      _index = _tabHistory.isEmpty ? 0 : _tabHistory.removeLast();
    });
    unawaited(widget.controller.recordScreenView(_screenFor(_index)));
  }

  LocalActivityScreen _screenFor(int index) => switch (index) {
    1 => LocalActivityScreen.prayers,
    2 => LocalActivityScreen.settings,
    _ => LocalActivityScreen.today,
  };

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    final isTablet = AppLayout.isTablet(context);
    final screens = [
      TodayScreen(controller: widget.controller),
      PrayerListScreen(
        controller: widget.controller,
        onHome: () => _selectTab(0),
      ),
      SettingsScreen(
        controller: widget.controller,
        updateService: widget.updateService,
      ),
    ];

    NavigationBar navigationBar({Color? backgroundColor}) => NavigationBar(
      backgroundColor: backgroundColor,
      selectedIndex: _index,
      onDestinationSelected: _selectTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny),
          label: 'Today',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Prayers',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );

    return PopScope(
      canPop: _index == 0 && _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: screens),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.controller.requiresSubscription)
              UpgradePrompt(
                onPressed: () async {
                  await showSubscriptionModal(
                    context,
                    subscriptionService: widget.controller.subscriptionService,
                  );
                },
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: semantic.subtleBorder)),
              ),
              child: isTablet
                  ? ColoredBox(
                      color: semantic.navigationBackground,
                      child: Center(
                        child: SizedBox(
                          key: const Key('tablet-navigation-content'),
                          width: AppLayout.tabletContentWidth,
                          child: navigationBar(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    )
                  : navigationBar(),
            ),
          ],
        ),
      ),
    );
  }
}
