import 'package:flutter/material.dart';

import '../data/festival_stats.dart';
import '../data/models.dart';
import '../data/queries.dart';
import 'charts.dart';
import 'context.dart';
import 'stat_grid.dart';
import 'wide.dart';
import 'widgets.dart';

class PlaceScreen extends StatefulWidget {
  const PlaceScreen({super.key, required this.queries, required this.id});

  final Queries queries;
  final String id;

  @override
  State<PlaceScreen> createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  late final _data = (() async =>
      (await widget.queries.place(widget.id), await widget.queries.placeRankings(widget.id)))();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Readable(
      width: pageWidth,
      child: Loader(
        future: _data,
        builder: (context, data) {
          final (place, rankings) = data;
          if (place == null) return Message(context.l10n.noData);
          final theme = Theme.of(context);
          final l10n = context.l10n;
          final summary = wreathSummary(rankings);
          final rounds = outcomesByRound(rankings);
          final surprises = upsets(rankings);
          final associations = byAssociation(rankings);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      [context.date(place.date), place.location, place.type].where((s) => s.isNotEmpty).join(' · '),
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Columns([
                if (rankings.isNotEmpty)
                  Section(
                    title: l10n.tabStatistics,
                    children: [
                      StatGrid([
                        StatTile(label: l10n.starters, value: '${summary.starters}'),
                        StatTile(label: l10n.wreathsWithRate(summary.wreathPercent), value: '${summary.wreaths}'),
                        StatTile(
                          label: l10n.wreathLine,
                          value: summary.wreathLine == null ? '–' : context.decimal(summary.wreathLine!),
                        ),
                      ]),
                      if (rounds.length >= 2)
                        OutcomeChart(
                          title: l10n.outcomesByRound,
                          winLabel: l10n.decided,
                          bars: [
                            for (final MapEntry(key: round, value: counts) in rounds.entries)
                              (label: '$round', name: l10n.round(round), counts: counts),
                          ],
                        ),
                    ],
                  ),
                if (surprises.isNotEmpty)
                  Section(
                    title: l10n.upsets,
                    subtitle: l10n.upsetsSubtitle(int.parse(yearOf(place.date)) - 1),
                    children: [
                      for (final u in surprises)
                        ListTile(
                          leading: Text(l10n.round(u.round)),
                          title: PersonName(u.winner),
                          subtitle: Text(l10n.upsetOver(u.loser.fullName, u.winnerElo.round(), u.loserElo.round())),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => openWrestler(context, widget.queries, u.winner.id),
                        ),
                    ],
                  ),
                if (associations.length >= 2)
                  Section(
                    title: l10n.byAssociation,
                    children: [
                      for (final a in associations)
                        ListTile(
                          dense: true,
                          title: Text(a.name),
                          trailing: Text(l10n.startersAndWreaths(a.starters, a.wreaths)),
                        ),
                    ],
                  ),
                Section(
                  title: context.l10n.rankings,
                  children: [
                    if (rankings.isEmpty)
                      Message(place.planned ? context.l10n.plannedNoResults : context.l10n.noResults),
                    for (final r in rankings) _RankingTile(queries: widget.queries, ranking: r),
                  ],
                ),
              ]),
            ],
          );
        },
      ),
    ),
  );
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.queries, required this.ranking});

  final Queries queries;
  final PlaceRanking ranking;

  @override
  Widget build(BuildContext context) {
    final wrestler = ranking.wrestler;
    return ExpansionTile(
      leading: RankBadge(ranking.rankLabel),
      title: wrestler == null ? const Text('–') : PersonName(wrestler),
      subtitle: ranking.status.isEmpty ? null : Text(ranking.status),
      trailing: Points(points: ranking.points, wreath: ranking.wreath),
      shape: const Border(),
      children: [
        for (final bout in ranking.bouts)
          ListTile(
            dense: true,
            leading: Text(context.l10n.round(bout.round)),
            title: bout.opponent == null ? const Text('–') : PersonName(bout.opponent!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [ResultMark(bout.result), const SizedBox(width: 8), Text(context.points(bout.points))],
            ),
            onTap: bout.opponent == null ? null : () => openWrestler(context, queries, bout.opponent!.id),
          ),
        if (wrestler != null)
          ListTile(
            dense: true,
            title: Text(context.l10n.openProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openWrestler(context, queries, wrestler.id),
          ),
      ],
    );
  }
}
