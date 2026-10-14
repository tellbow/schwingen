import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../data/bug_report.dart';
import '../data/queries.dart';
import 'bug_report_sheet.dart';
import 'context.dart';
import 'groups_screen.dart';
import 'head_to_head_screen.dart';
import 'place_observer.dart';
import 'places_screen.dart';
import 'statistics_screen.dart';
import 'wrestlers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.queries,
    required this.settings,
    required this.client,
    required this.dataTag,
    this.banner,
  });

  final Queries queries;
  final WidgetBuilder settings;
  final http.Client client;
  final String? dataTag;
  final Widget? banner;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _places = ['/wrestler', '/places', '/head2head', '/associations', '/statistics'];

  final _navigators = List.generate(5, (_) => GlobalKey<NavigatorState>());
  final _observers = [for (final place in _places) PlaceObserver(place)];
  var _tab = 0;

  Widget _root(int tab) => switch (tab) {
    0 => WrestlersScreen(queries: widget.queries, onSettings: _openSettings),
    1 => PlacesScreen(queries: widget.queries, onSettings: _openSettings),
    2 => HeadToHeadScreen(queries: widget.queries, onSettings: _openSettings),
    3 => AssociationsScreen(queries: widget.queries, onSettings: _openSettings),
    _ => StatisticsScreen(queries: widget.queries, onSettings: _openSettings),
  };

  void _openSettings() => _navigators[_tab].currentState?.push(
    MaterialPageRoute(
      settings: const RouteSettings(name: '/settings'),
      builder: widget.settings,
    ),
  );

  Future<void> _sendBugReport(String description, String place) async {
    final info = await PackageInfo.fromPlatform();
    await sendBugReport(
      widget.client,
      description: description,
      place: place,
      version: '${info.version} (${info.buildNumber}) · ${widget.dataTag ?? '–'}',
      system: 'iOS ${Platform.operatingSystemVersion}',
    );
  }

  void _openBugReport() {
    final place = _observers[_tab].place;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BugReportSheet(place: place, send: (description) => _sendBugReport(description, place)),
    );
  }

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
            child: Stack(
              children: [
                IndexedStack(
                  index: _tab,
                  children: [
                    for (var i = 0; i < _navigators.length; i++)
                      Navigator(
                        key: _navigators[i],
                        observers: [_observers[i]],
                        onGenerateRoute: (_) => MaterialPageRoute(
                          settings: RouteSettings(name: _places[i]),
                          builder: (_) => _root(i),
                        ),
                      ),
                  ],
                ),
                Positioned(right: 0, bottom: 24, child: _BugTab(onTap: _openBugReport)),
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

class _BugTab extends StatelessWidget {
  const _BugTab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const shape = BorderRadius.horizontal(left: Radius.circular(8));
    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.9),
      borderRadius: shape,
      elevation: 2,
      child: InkWell(
        borderRadius: shape,
        onTap: onTap,
        child: Tooltip(
          message: context.l10n.bugReport,
          child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.bug_report_outlined, size: 20)),
        ),
      ),
    );
  }
}
