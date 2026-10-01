import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../state/medix_state.dart';
import '../favorites/favorites_screen.dart';
import '../search/search_screen.dart';
import '../settings/more_screen.dart';
import '../therapy/therapy_screen.dart';
import 'home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.state,
    super.key,
  });

  final MedixState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        state: widget.state,
        onSearchRequested: () => setState(() => index = 1),
      ),
      SearchScreen(state: widget.state),
      TherapyScreen(state: widget.state),
      FavoritesScreen(state: widget.state),
      MoreScreen(state: widget.state),
    ];

    return Scaffold(
      backgroundColor: MedixColors.background,
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Pretraga',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Terapija',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoriti',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Više',
          ),
        ],
      ),
    );
  }
}
