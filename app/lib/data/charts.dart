import 'dart:math';

import 'models.dart';
import 'stats.dart';

class FestivalResult {
  const FestivalResult(this.date, this.rank, this.points, this.ranking);

  final DateTime date;
  final int? rank;
  final double? points;
  final Ranking ranking;
}

List<FestivalResult> festivalResults(List<Ranking> rankings) => [
  for (final r in rankings)
    if (r.status != 'Unfall')
      if (DateTime.tryParse(r.place.date) case final date?)
        FestivalResult(
          date,
          int.tryParse(r.rank.replaceAll(RegExp(r'\D'), '')),
          r.place.type.contains('idgenössisch') ? null : double.tryParse(r.points),
          r,
        ),
]..sort((a, b) => a.date.compareTo(b.date));

Map<int, double?> averageRankBySeason(List<Ranking> rankings) => {
  for (final MapEntry(key: year, value: season) in bySeason(rankings).entries) year: averageRank(season),
};

List<String> monthLabels(List<DateTime> dates, String Function(DateTime) format) {
  final labels = <String>[];
  for (final (i, date) in dates.indexed) {
    final starts = i == 0 || dates[i - 1].month != date.month;
    labels.add(starts && (i == 0 || labels[i - 1].isEmpty) ? format(date) : '');
  }
  return labels;
}

List<double> shareOfMax(List<num> values) {
  final top = values.fold<num>(0, max);
  return [for (final v in values) top <= 0 ? 0 : v / top];
}
