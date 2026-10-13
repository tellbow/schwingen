import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.title, required this.points, required this.format, this.range});

  final String title;
  final List<(int, num?)> points;
  final String Function(num) format;
  final AxisRange? range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = seriesColor(scheme);
    final known = [
      for (final (year, value) in points)
        if (value != null) (year, value),
    ];
    final axis = range ?? axisRange([for (final (_, value) in known) value]);
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final tick = NumberFormat(axis.step < 1 ? '0.#' : '0', Localizations.localeOf(context).toString());
    final (lastYear, lastValue) = known.last;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              Text(format(lastValue), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(' ($lastYear)', style: muted),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: points.first.$1.toDouble(),
                maxX: points.last.$1.toDouble(),
                minY: axis.min,
                maxY: axis.max,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: axis.step,
                  getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text('’${(value.toInt() % 100).toString().padLeft(2, '0')}', style: muted),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: axis.step,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(tick.format(value), style: muted),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (_) => scheme.inverseSurface,
                    getTooltipItems: (spots) => [
                      for (final spot in spots)
                        LineTooltipItem(
                          '${spot.x.toInt()}: ${format(spot.y)}',
                          TextStyle(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (final (year, value) in points)
                        value == null ? FlSpot.nullSpot : FlSpot(year.toDouble(), value.toDouble()),
                    ],
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    isStrokeJoinRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: scheme.surfaceContainerLowest,
                      ),
                    ),
                    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AxisRange {
  const AxisRange(this.min, this.max, this.step);

  final double min;
  final double max;
  final double step;
}

AxisRange axisRange(List<num> values) {
  final low = values.reduce(min).toDouble(), high = values.reduce(max).toDouble();
  final raw = max(high - low, 1) / 4;
  final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
  final fraction = raw / magnitude;
  final step =
      (fraction <= 1
          ? 1
          : fraction <= 2
          ? 2
          : fraction <= 5
          ? 5
          : 10) *
      magnitude;
  final bottom = (low / step).floor() * step;
  final top = (high / step).ceil() * step;
  return AxisRange(bottom, top == bottom ? top + step : top, step);
}
