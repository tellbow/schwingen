import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'wide.dart';
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
  final _boundary = GlobalKey();
  var _tab = 0;
  var _taking = false;

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

  Future<void> _sendBugReport(String description, String place, Uint8List? screenshot) async {
    final info = await PackageInfo.fromPlatform();
    await sendBugReport(
      widget.client,
      description: description,
      place: place,
      version: '${info.version} (${info.buildNumber}) · ${widget.dataTag ?? '–'}',
      system: 'iOS ${Platform.operatingSystemVersion}',
      screenshot: screenshot,
    );
  }

  Future<Uint8List?> _screenshot() async {
    try {
      final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 2);
      final png = await image?.toByteData(format: ui.ImageByteFormat.png);
      image?.dispose();
      final bytes = png?.buffer.asUint8List();
      return bytes != null && bytes.length <= maxScreenshotBytes ? bytes : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openBugReport() async {
    if (_taking) return;
    final place = _observers[_tab].place;
    setState(() => _taking = true);
    await WidgetsBinding.instance.endOfFrame;
    final screenshot = await _screenshot();
    if (!mounted) return;
    setState(() => _taking = false);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BugReportSheet(
        place: place,
        screenshot: screenshot,
        send: (description, screenshot) => _sendBugReport(description, place, screenshot),
      ),
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
    final wide = isWide(context);
    final tabs = [
      (Icons.people_outline, l10n.tabWrestlers),
      (Icons.emoji_events_outlined, l10n.navPlaces),
      (Icons.compare_arrows, l10n.navHeadToHead),
      (Icons.account_tree_outlined, l10n.tabAssociations),
      (Icons.bar_chart, l10n.tabStatistics),
    ];
    final pages = Column(
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
              if (!_taking) Positioned(right: 0, bottom: 24, child: _BugTab(onTap: _openBugReport)),
            ],
          ),
        ),
        ?widget.banner,
      ],
    );
    return RepaintBoundary(
      key: _boundary,
      child: Scaffold(
        body: Row(
          children: [
            if (wide)
              SafeArea(
                right: false,
                child: NavigationRail(
                  selectedIndex: _tab,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  groupAlignment: 0,
                  destinations: [
                    for (final (icon, label) in tabs) NavigationRailDestination(icon: Icon(icon), label: Text(label)),
                  ],
                ),
              ),
            if (wide) const VerticalDivider(width: 1),
            Expanded(
              key: const Key('pages'),
              child: MediaQuery.removePadding(context: context, removeLeft: wide, child: pages),
            ),
          ],
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: _select,
                destinations: [for (final (icon, label) in tabs) NavigationDestination(icon: Icon(icon), label: label)],
              ),
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
