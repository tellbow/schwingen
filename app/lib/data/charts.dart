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

class PointsBin {
  const PointsBin(this.from, this.wreath, this.other);

  final double from;
  final int wreath;
  final int other;

  int get total => wreath + other;
}

List<PointsBin> pointsHistogram(List<PlaceRanking> rankings, {double width = 0.5}) {
  final scored = [
    for (final r in rankings)
      if (double.tryParse(r.points) case final points? when points > 0) ((points / width).floor(), r.wreath),
  ];
  if (scored.isEmpty) return const [];
  final first = scored.map((s) => s.$1).reduce(min), last = scored.map((s) => s.$1).reduce(max);
  final wreath = List.filled(last - first + 1, 0), other = List.filled(last - first + 1, 0);
  for (final (bin, won) in scored) {
    (won ? wreath : other)[bin - first]++;
  }
  return [for (var i = 0; i <= last - first; i++) PointsBin((first + i) * width, wreath[i], other[i])];
}

List<double> shareOfMax(List<num> values) {
  final top = values.fold<num>(0, max);
  return [for (final v in values) top <= 0 ? 0 : v / top];
}
