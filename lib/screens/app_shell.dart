import 'package:flutter/material.dart';

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

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final List<int> _tabHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final service = widget.updateService;
    if (service == null) return;

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
    } catch (_) {
      // An update check must never prevent the app from opening.
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
    final screens = [
      TodayScreen(controller: widget.controller),
      PrayerListScreen(
        controller: widget.controller,
        favoritesOnly: false,
        onHome: () => _selectTab(0),
      ),
      PrayerListScreen(
        controller: widget.controller,
        favoritesOnly: true,
        onExplorePrayers: () => _selectTab(1),
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
        bottomNavigationBar: NavigationBar(
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
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
