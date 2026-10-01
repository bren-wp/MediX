import 'package:flutter/material.dart';

import '../../state/medix_state.dart';
import '../categories/categories_screen.dart';
import '../favorites/favorites_screen.dart';
import '../interactions/interactions_screen.dart';
import '../search/search_screen.dart';
import '../settings/more_screen.dart';
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
        onCategoriesRequested: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoriesScreen(state: widget.state),
            ),
          );
        },
      ),
      SearchScreen(state: widget.state),
      FavoritesScreen(state: widget.state),
      InteractionsScreen(state: widget.state),
      const MoreScreen(),
    ];

    return Scaffold(
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
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoriti',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Interakcije',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Više',
          ),
        ],
      ),
    );
  }
}
