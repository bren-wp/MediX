import 'package:flutter/material.dart';

import '../../core/theme/medix_theme.dart';
import '../../core/localization/medix_localizations.dart';
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
  // IndexedStack retains visited tabs, but only builds a heavy page on first
  // use. In particular SearchScreen must not index thousands of medicines
  // on the very first frame of the home screen.
  final Set<int> _visitedTabs = {0};
  late final List<Widget> pages;

  void _selectTab(int next) {
    setState(() {
      index = next;
      _visitedTabs.add(next);
    });
  }

  @override
  void initState() {
    super.initState();
    pages = <Widget>[
      HomeScreen(
        state: widget.state,
        onSearchRequested: () => _selectTab(1),
      ),
      SearchScreen(state: widget.state),
      TherapyScreen(state: widget.state),
      FavoritesScreen(state: widget.state),
      MoreScreen(state: widget.state),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = MedixLocalizations.of(context);
    return Scaffold(
      backgroundColor: MedixColors.background,
      body: IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < pages.length; i++)
            if (_visitedTabs.contains(i))
              pages[i]
            else
              const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: loc.t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: loc.t('search'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            selectedIcon: const Icon(Icons.event_note_rounded),
            label: loc.t('therapy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: loc.t('favorites'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: loc.t('more'),
          ),
        ],
      ),
    );
  }
}
