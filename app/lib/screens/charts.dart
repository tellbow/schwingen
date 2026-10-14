import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/charts.dart';
import '../data/stats.dart';
import '../theme.dart';
import 'context.dart';
import 'trend_chart.dart';

class ChartFrame extends StatelessWidget {
  const ChartFrame({super.key, required this.title, required this.chart, this.legend = const [], this.height = 160});

  final String title;
  final Widget chart;
  final List<(Color, String)> legend;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          if (legend.isNotEmpty) ...[const SizedBox(height: 6), Legend(legend)],
          const SizedBox(height: 16),
          SizedBox(height: height, child: chart),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  const Legend(this.entries, {super.key});

  final List<(Color, String)> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (color, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 4),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
      ],
    );
  }
}

class SeasonOutcomeChart extends StatelessWidget {
  const SeasonOutcomeChart(this.trends, {super.key});

  final List<SeasonTrend> trends;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final colors = outcomeColors(scheme);
    final seasons = trends.where((t) => t.counts.total > 0).toList();
    return ChartFrame(
      title: l10n.outcomesBySeason,
      legend: [(colors.win, l10n.wins), (colors.draw, l10n.draws), (colors.loss, l10n.losses)],
      chart: LayoutBuilder(
        builder: (context, constraints) => BarChart(
          BarChartData(
            minY: 0,
            maxY: 100,
            borderData: FlBorderData(show: false),
            gridData: _grid(scheme, 50),
            titlesData: _titles(
              context,
              bottom: (value) => shortYear(seasons[value.toInt()].year),
              leftStep: 50,
              left: (value) => '${value.round()} %',
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                maxContentWidth: 220,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (_) => scheme.inverseSurface,
                getTooltipItem: (group, _, _, _) {
                  final t = seasons[group.x];
                  return BarTooltipItem(
                    '${t.year}\n${t.counts.wins} ${l10n.wins} · ${t.counts.draws} ${l10n.draws} · '
                    '${t.counts.losses} ${l10n.losses}',
                    _tooltipStyle(scheme),
                  );
                },
              ),
            ),
            barGroups: [
              for (final (i, t) in seasons.indexed)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: 100,
                      color: Colors.transparent,
                      width: _rodWidth(constraints.maxWidth, seasons.length),
                      borderRadius: BorderRadius.circular(4),
                      rodStackItems: _stack([
                        (t.counts.wins * 100 / t.counts.total, colors.win),
                        (t.counts.draws * 100 / t.counts.total, colors.draw),
                        (t.counts.losses * 100 / t.counts.total, colors.loss),
                      ], scheme),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FestivalChart extends StatelessWidget {
  const FestivalChart({super.key, required this.title, required this.results, required this.rank});

  final String title;
  final List<FestivalResult> results;
  final bool rank;

  static bool hasData(List<FestivalResult> results, {required bool rank}) =>
      results.where((r) => (rank ? r.rank : r.points) != null).length >= 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final color = seriesColor(scheme);
    final shown = [
      for (final r in results)
        if ((rank ? r.rank?.toDouble() : r.points) case final value?) (r, value),
    ];
    final axis = axisRange([for (final (_, value) in shown) value]);
    final days = [for (final (r, _) in shown) _dayOfYear(r.date)];
    final month = DateFormat.MMM(context.localeName);
    final year = shown.first.$1.date.year;
    final spots = [
      for (final (i, (_, value)) in shown.indexed)
        ScatterSpot(
          days[i].toDouble(),
          rank ? -value : value,
          dotPainter: FlDotCirclePainter(
            radius: 5,
            color: color,
            strokeWidth: 2,
            strokeColor: scheme.surfaceContainerLowest,
          ),
        ),
    ];
    return ChartFrame(
      title: title,
      chart: ScatterChart(
        ScatterChartData(
          scatterSpots: spots,
          minX: days.reduce(min) - 10.0,
          maxX: days.reduce(max) + 10.0,
          minY: rank ? -axis.max : axis.min,
          maxY: rank ? -axis.min : axis.max,
          borderData: FlBorderData(show: false),
          gridData: _grid(scheme, axis.step),
          titlesData: _titles(
            context,
            bottom: (value) {
              final date = DateTime.utc(year, 1, 1 + value.toInt());
              return date.day == 1 ? month.format(date) : '';
            },
            leftStep: axis.step,
            left: (value) => rank
                ? (value >= 0 ? '' : '${-value.round()}')
                : NumberFormat(axis.step < 1 ? '0.#' : '0', context.localeName).format(value),
          ),
          scatterTouchData: ScatterTouchData(
            touchTooltipData: ScatterTouchTooltipData(
              maxContentWidth: 220,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spot) {
                final (r, _) = shown[spots.indexOf(spot)];
                return ScatterTooltipItem(
                  '${r.ranking.place.name}\n${l10n.rankAndPoints(r.ranking.rankLabel, context.points(r.ranking.points))}',
                  textStyle: _tooltipStyle(scheme),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RankDuelChart extends StatelessWidget {
  const RankDuelChart({super.key, required this.series});

  final List<(String, Map<int, double?>)> series;

  static bool hasData(List<(String, Map<int, double?>)> series) =>
      {
        for (final (_, byYear) in series)
          for (final MapEntry(:key, :value) in byYear.entries)
            if (value != null) key,
      }.length >=
      2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final colors = [seriesColor(scheme), secondSeriesColor(scheme)];
    final known = [
      for (final (_, byYear) in series)
        for (final MapEntry(:key, :value) in byYear.entries)
          if (value != null) (key, value),
    ];
    final first = known.map((k) => k.$1).reduce(min), last = known.map((k) => k.$1).reduce(max);
    final axis = axisRange([for (final (_, value) in known) value]);
    return ChartFrame(
      title: l10n.rankBySeason,
      legend: [for (final (i, (name, _)) in series.indexed) (colors[i], name)],
      chart: LineChart(
        LineChartData(
          minX: first.toDouble(),
          maxX: last.toDouble(),
          minY: -axis.max,
          maxY: -axis.min,
          borderData: FlBorderData(show: false),
          gridData: _grid(scheme, axis.step),
          titlesData: _titles(
            context,
            bottom: (value) => shortYear(value.toInt()),
            leftStep: axis.step,
            left: (value) => value >= 0 ? '' : NumberFormat('0.#', context.localeName).format(-value),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 220,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    '${spot.x.toInt()} ${series[spot.barIndex].$1}: ${context.decimal(-spot.y)}',
                    _tooltipStyle(scheme),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            for (final (i, (_, byYear)) in series.indexed)
              LineChartBarData(
                spots: [
                  for (var y = first; y <= last; y++)
                    byYear[y] == null ? FlSpot.nullSpot : FlSpot(y.toDouble(), -byYear[y]!),
                ],
                color: colors[i],
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                    radius: 4,
                    color: colors[i],
                    strokeWidth: 2,
                    strokeColor: scheme.surfaceContainerLowest,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PointsHistogramChart extends StatelessWidget {
  const PointsHistogramChart(this.bins, {super.key, this.width = 0.5});

  final List<PointsBin> bins;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final wreath = seriesColor(scheme), other = outcomeColors(scheme).draw;
    final axis = axisRange([0, ...bins.map((b) => b.total)]);
    final step = max(axis.step, 1.0);
    return ChartFrame(
      title: l10n.pointsDistribution,
      legend: [(wreath, l10n.withWreathLegend), (other, l10n.withoutWreath)],
      chart: LayoutBuilder(
        builder: (context, constraints) => BarChart(
          BarChartData(
            minY: 0,
            maxY: (axis.max / step).ceil() * step,
            borderData: FlBorderData(show: false),
            gridData: _grid(scheme, step),
            titlesData: _titles(
              context,
              bottom: (value) {
                final from = bins[value.toInt()].from;
                return from == from.roundToDouble() ? '${from.round()}' : '';
              },
              leftStep: step,
              left: (value) => '${value.round()}',
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                maxContentWidth: 220,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (_) => scheme.inverseSurface,
                getTooltipItem: (group, _, _, _) {
                  final b = bins[group.x];
                  return BarTooltipItem(
                    '${context.decimal(b.from)}–${context.decimal(b.from + width - 0.25)}\n'
                    '${b.wreath} ${l10n.withWreathLegend} · ${b.other} ${l10n.withoutWreath}',
                    _tooltipStyle(scheme),
                  );
                },
              ),
            ),
            barGroups: [
              for (final (i, b) in bins.indexed)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: b.total.toDouble(),
                      color: Colors.transparent,
                      width: _rodWidth(constraints.maxWidth, bins.length),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      rodStackItems: _stack([(b.wreath.toDouble(), wreath), (b.other.toDouble(), other)], scheme),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

int _dayOfYear(DateTime date) => date.difference(DateTime.utc(date.year)).inDays;

double _rodWidth(double chartWidth, int count) => ((chartWidth - 48) / max(count, 1) * 0.6).clamp(4, 20);

List<BarChartRodStackItem> _stack(List<(double, Color)> parts, ColorScheme scheme) {
  var from = 0.0;
  return [
    for (final (size, color) in parts)
      if (size > 0)
        BarChartRodStackItem(
          from,
          from += size,
          color,
          borderSide: BorderSide(color: scheme.surfaceContainerLowest, width: 1),
        ),
  ];
}

TextStyle _tooltipStyle(ColorScheme scheme) => TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w600);

FlGridData _grid(ColorScheme scheme, double step) => FlGridData(
  drawVerticalLine: false,
  horizontalInterval: step,
  getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 1),
);

FlTitlesData _titles(
  BuildContext context, {
  required String Function(double) bottom,
  required double leftStep,
  required String Function(double) left,
}) {
  final theme = Theme.of(context);
  final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
  return FlTitlesData(
    topTitles: const AxisTitles(),
    rightTitles: const AxisTitles(),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: 1,
        reservedSize: 22,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          child: Text(bottom(value), style: muted),
        ),
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        interval: leftStep,
        reservedSize: 48,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          meta: meta,
          child: Text(left(value), style: muted),
        ),
      ),
    ),
  );
}
