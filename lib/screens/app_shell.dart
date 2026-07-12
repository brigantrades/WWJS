import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import 'prayer_list_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(controller: widget.controller),
      PrayerListScreen(
        controller: widget.controller,
        favoritesOnly: false,
        onHome: () => setState(() => _index = 0),
      ),
      PrayerListScreen(
        controller: widget.controller,
        favoritesOnly: true,
        onExplorePrayers: () => setState(() => _index = 1),
        onHome: () => setState(() => _index = 0),
      ),
      SettingsScreen(controller: widget.controller),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
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
    );
  }
}
