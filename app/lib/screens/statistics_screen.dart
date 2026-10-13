import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/queries.dart';
import '../data/statistics_queries.dart';
import 'context.dart';
import 'widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.queries, required this.dataTag});

  final Queries queries;
  final String? dataTag;

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
      appBar: AppBar(title: Text(l10n.tabStatistics)),
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
                  ),
                  _Top(queries: widget.queries, title: l10n.topWreaths, entries: stats.mostWreaths, value: whole),
                  _Top(queries: widget.queries, title: l10n.topPlaces, entries: stats.mostPlacesAttended, value: whole),
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
          if (widget.dataTag != null)
            Padding(padding: const EdgeInsets.only(top: 16), child: Message(l10n.dataVersion(widget.dataTag!))),
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
  });

  final Queries queries;
  final String title;
  final String? subtitle;
  final List<StatEntry> entries;
  final String Function(StatEntry) value;
  final String Function(StatEntry)? detail;

  @override
  Widget build(BuildContext context) => Section(
    title: title,
    subtitle: subtitle,
    children: [
      if (entries.isEmpty) Message(context.l10n.noData),
      for (final (i, e) in entries.indexed)
        ListTile(
          dense: true,
          leading: Text('${i + 1}.', style: const TextStyle(fontWeight: FontWeight.w600)),
          title: PersonName(e.person),
          subtitle: detail == null ? null : Text(detail!(e)),
          trailing: Text(value(e), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          onTap: () => openWrestler(context, queries, e.person.id),
        ),
    ],
  );
}
