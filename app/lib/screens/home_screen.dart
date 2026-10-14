import 'package:flutter/material.dart';

import '../data/queries.dart';
import 'context.dart';
import 'groups_screen.dart';
import 'head_to_head_screen.dart';
import 'places_screen.dart';
import 'statistics_screen.dart';
import 'wrestlers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.queries, required this.settings, this.banner});

  final Queries queries;
  final WidgetBuilder settings;
  final Widget? banner;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _navigators = List.generate(5, (_) => GlobalKey<NavigatorState>());
  var _tab = 0;

  Widget _root(int tab) => switch (tab) {
    0 => WrestlersScreen(queries: widget.queries, onSettings: _openSettings),
    1 => PlacesScreen(queries: widget.queries, onSettings: _openSettings),
    2 => HeadToHeadScreen(queries: widget.queries, onSettings: _openSettings),
    3 => AssociationsScreen(queries: widget.queries, onSettings: _openSettings),
    _ => StatisticsScreen(queries: widget.queries, onSettings: _openSettings),
  };

  void _openSettings() => _navigators[_tab].currentState?.push(MaterialPageRoute(builder: widget.settings));

  void _select(int tab) {
    if (tab == _tab) {
      _navigators[tab].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _tab = tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                for (var i = 0; i < _navigators.length; i++)
                  Navigator(
                    key: _navigators[i],
                    onGenerateRoute: (settings) => MaterialPageRoute(settings: settings, builder: (_) => _root(i)),
                  ),
              ],
            ),
          ),
          ?widget.banner,
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.people_outline), label: l10n.tabWrestlers),
          NavigationDestination(icon: const Icon(Icons.emoji_events_outlined), label: l10n.navPlaces),
          NavigationDestination(icon: const Icon(Icons.compare_arrows), label: l10n.navHeadToHead),
          NavigationDestination(icon: const Icon(Icons.account_tree_outlined), label: l10n.tabAssociations),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: l10n.tabStatistics),
        ],
      ),
    );
  }
}
