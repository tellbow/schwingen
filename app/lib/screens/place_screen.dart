import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/queries.dart';
import 'context.dart';
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
    body: Loader(
      future: _data,
      builder: (context, data) {
        final (place, rankings) = data;
        if (place == null) return Message(context.l10n.noData);
        final theme = Theme.of(context);
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
            Section(
              title: context.l10n.rankings,
              children: [
                if (rankings.isEmpty) Message(context.l10n.noResults),
                for (final r in rankings) _RankingTile(queries: widget.queries, ranking: r),
              ],
            ),
          ],
        );
      },
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
