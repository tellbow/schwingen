import 'package:flutter/material.dart';

import '../data/charts.dart';
import '../data/models.dart';
import '../data/queries.dart';
import '../data/statistics_queries.dart';
import '../theme.dart';
import 'context.dart';
import 'widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.queries, required this.onSettings});

  final Queries queries;
  final VoidCallback onSettings;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final _years = widget.queries.seasons();
  int? _year;
  late Future<Statistics> _stats = widget.queries.statistics(_year);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStatistics), actions: [SettingsButton(widget.onSettings)]),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          FutureBuilder(
            future: _years,
            builder: (context, snapshot) => YearChips(
              years: snapshot.data ?? const [],
              selected: _year,
              onSelected: (year) => setState(() {
                _year = year;
                _stats = widget.queries.statistics(year);
              }),
            ),
          ),
          Loader(
            future: _stats,
            builder: (context, stats) {
              String decimal(StatEntry e) => context.decimal(e.value);
              String whole(StatEntry e) => '${e.value.round()}';
              return Column(
                children: [
                  if (_year != null)
                    _Top(queries: widget.queries, title: l10n.topElo, entries: stats.elo, value: whole),
                  _Top(
                    queries: widget.queries,
                    title: l10n.topAvgRank,
                    subtitle: _year == null ? null : l10n.fiveEvents,
                    entries: stats.averageRank,
                    value: decimal,
                  ),
                  _Top(
                    queries: widget.queries,
                    title: l10n.topAvgPoints,
                    subtitle: _year == null ? null : l10n.fiveEvents,
                    entries: stats.averagePoints,
                    value: decimal,
                  ),
                  _Top(
                    queries: widget.queries,
                    title: l10n.topWins,
                    entries: stats.mostWins,
                    value: whole,
                    detail: (e) => l10n.withWreath(e.extra?.round() ?? 0),
                    bars: true,
                  ),
                  _Top(
                    queries: widget.queries,
                    title: l10n.topWreaths,
                    entries: stats.mostWreaths,
                    value: whole,
                    bars: true,
                  ),
                  _Top(
                    queries: widget.queries,
                    title: l10n.topPlaces,
                    entries: stats.mostPlacesAttended,
                    value: whole,
                    bars: true,
                  ),
                  Section(
                    title: l10n.drawRatio,
                    subtitle: l10n.drawRatioCaption,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          stats.drawPercent == null ? '–' : '${stats.drawPercent} %',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({
    required this.queries,
    required this.title,
    required this.entries,
    required this.value,
    this.subtitle,
    this.detail,
    this.bars = false,
  });

  final Queries queries;
  final String title;
  final String? subtitle;
  final List<StatEntry> entries;
  final String Function(StatEntry) value;
  final String Function(StatEntry)? detail;
  final bool bars;

  @override
  Widget build(BuildContext context) {
    final shares = shareOfMax([for (final e in entries) e.value]);
    return Section(
      title: title,
      subtitle: subtitle,
      children: [
        if (entries.isEmpty) Message(context.l10n.noData),
        for (final (i, e) in entries.indexed)
          ListTile(
            dense: true,
            leading: Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.w600)),
            title: bars ? _Bar(share: shares[i], child: PersonName(e.person)) : PersonName(e.person),
            subtitle: detail == null ? null : Text(detail!(e)),
            trailing: Text(value(e), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            onTap: () => openWrestler(context, queries, e.person.id),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.share, required this.child});

  final double share;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      child,
      const SizedBox(height: 4),
      FractionallySizedBox(
        widthFactor: share,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: seriesColor(Theme.of(context).colorScheme),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ],
  );
}
