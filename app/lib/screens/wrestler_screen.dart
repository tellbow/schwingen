import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../data/queries.dart';
import '../data/stats.dart';
import 'context.dart';
import 'stat_grid.dart';
import 'trend_chart.dart';
import 'widgets.dart';

typedef _Season = ({List<Ranking> rankings, List<OpponentRecord> opponents, Elo? elo, List<Elo> eloHistory});

class WrestlerScreen extends StatefulWidget {
  const WrestlerScreen({super.key, required this.queries, required this.id});

  final Queries queries;
  final String id;

  @override
  State<WrestlerScreen> createState() => _WrestlerScreenState();
}

class _WrestlerScreenState extends State<WrestlerScreen> {
  late final _base = (() async => (await widget.queries.wrestler(widget.id), await widget.queries.seasons()))();
  late Future<_Season> _season = _load();
  int? _year;

  Future<_Season> _load() async {
    final q = widget.queries;
    return (
      rankings: await q.rankingsOf(widget.id, _year),
      opponents: await q.opponents(widget.id, _year),
      elo: await q.elo(widget.id, _year),
      eloHistory: _year == null ? await q.eloHistory(widget.id) : const <Elo>[],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Loader(
      future: _base,
      builder: (context, base) {
        final (detail, years) = base;
        if (detail == null) return Message(context.l10n.noData);
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(queries: widget.queries, detail: detail),
            const SizedBox(height: 8),
            YearChips(
              years: years,
              selected: _year,
              onSelected: (year) => setState(() {
                _year = year;
                _season = _load();
              }),
            ),
            Loader(
              future: _season,
              builder: (context, season) =>
                  _SeasonView(queries: widget.queries, wrestler: detail.person, season: season),
            ),
          ],
        );
      },
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.queries, required this.detail});

  final Queries queries;
  final WrestlerDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = [detail.club, detail.canton, detail.association].where((s) => s.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonName(detail.person, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (detail.status.isNotEmpty) Text(detail.status, style: TextStyle(color: theme.colorScheme.primary)),
          if (place.isNotEmpty)
            InkWell(
              onTap: detail.clubId.isEmpty ? null : () => openGroup(context, queries, GroupLevel.club, detail.clubId),
              child: Text(
                place,
                style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
              ),
            ),
          if (detail.year.isNotEmpty) Text('${context.l10n.yearOfBirth} ${detail.year}'),
          if (detail.website.isNotEmpty || detail.instagram.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                if (detail.website.isNotEmpty) _Link(icon: Icons.language, label: 'Website', url: detail.website),
                if (detail.instagram.isNotEmpty)
                  _Link(icon: Icons.photo_camera_outlined, label: 'Instagram', url: detail.instagram),
              ],
            ),
        ],
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.icon, required this.label, required this.url});

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 18),
    label: Text(label),
    onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
  );
}

class _SeasonView extends StatelessWidget {
  const _SeasonView({required this.queries, required this.wrestler, required this.season});

  final Queries queries;
  final Person wrestler;
  final _Season season;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final counts = boutCounts(season.rankings.map((r) => r.result));
    final wreaths = wreathCounts(season.rankings);
    final rank = averageRank(season.rankings);
    final points = averagePoints(season.rankings);
    final elo = season.elo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatGrid([
          StatTile(label: elo == null ? 'ELO' : l10n.eloOfYear(elo.year), value: elo?.rating.round().toString() ?? '–'),
          StatTile(label: l10n.averageRank, value: rank == null ? '–' : context.decimal(rank)),
          StatTile(label: l10n.averagePoints, value: points == null ? '–' : context.decimal(points)),
          StatTile(label: l10n.winsWithRate(counts.winPercent), value: '${counts.wins}', color: scheme.tertiary),
          StatTile(label: l10n.draws, value: '${counts.draws}'),
          StatTile(label: l10n.losses, value: '${counts.losses}', color: scheme.error),
          StatTile(label: l10n.wreathCantonal, value: '${wreaths.cantonal}'),
          StatTile(label: l10n.wreathRegional, value: '${wreaths.regional}'),
          StatTile(label: l10n.wreathFederal, value: '${wreaths.federal}'),
        ]),
        Section(
          title: l10n.rankings,
          children: [
            if (season.rankings.isEmpty) Message(l10n.noResults),
            for (final r in season.rankings)
              ListTile(
                leading: RankBadge(r.rankLabel),
                title: Text(r.place.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text([context.date(r.place.date), r.result, r.status].where((s) => s.isNotEmpty).join(' · ')),
                trailing: Points(points: r.points, wreath: r.wreath),
                onTap: () => openPlace(context, queries, r.place.id),
              ),
          ],
        ),
        if (season.eloHistory.isNotEmpty || season.rankings.isNotEmpty) _Trends(season),
        if (season.opponents.isNotEmpty)
          Section(
            title: l10n.opponents,
            children: [
              for (final o in season.opponents)
                ListTile(
                  title: PersonName(o.opponent),
                  subtitle: Text('${o.wins} ${l10n.wins} · ${o.draws} ${l10n.draws} · ${o.losses} ${l10n.losses}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openHeadToHead(context, queries, wrestler, o.opponent),
                ),
            ],
          ),
      ],
    );
  }
}

class _Trends extends StatelessWidget {
  const _Trends(this.season);

  final _Season season;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trends = seasonTrends(season.rankings);
    final elo = {for (final e in season.eloHistory) e.year: e.rating};
    final wins = {for (final t in trends) t.year: t.winPercent};
    final points = {for (final t in trends) t.year: t.averagePoints};
    final charts = [
      if (yearSeries(elo) case final s when s.isNotEmpty)
        TrendChart(title: 'ELO', points: s, format: (v) => '${v.round()}'),
      if (yearSeries(wins) case final s when s.isNotEmpty)
        TrendChart(title: l10n.winRate, points: s, format: (v) => '${v.round()} %', range: const AxisRange(0, 100, 25)),
      if (yearSeries(points) case final s when s.isNotEmpty)
        TrendChart(title: l10n.averagePoints, points: s, format: context.decimal),
    ];
    if (charts.isEmpty) return const SizedBox();
    return Section(title: l10n.trends, children: charts);
  }
}
