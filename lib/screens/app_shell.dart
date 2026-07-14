import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/app_update_service.dart';
import '../state/app_controller.dart';
import '../widgets/update_modal.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleUpdateCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _scheduleUpdateCheck();
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
        if (!opened && mounted) {
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
  }

  void _goBack() {
    setState(() {
      _index = _tabHistory.isEmpty ? 0 : _tabHistory.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
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
    return PopScope(
      canPop: _index == 0 && _tabHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: screens),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: semantic.subtleBorder)),
          ),
          child: NavigationBar(
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
          ),
        ),
      ),
    );
  }
}
