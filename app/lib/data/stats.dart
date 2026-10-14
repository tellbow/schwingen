import 'models.dart';

class BoutCounts {
  const BoutCounts(this.wins, this.draws, this.losses);

  final int wins;
  final int draws;
  final int losses;

  int get total => wins + draws + losses;

  int get winPercent => total == 0 ? 0 : (wins * 100 / total).round();
}

class WreathCounts {
  const WreathCounts(this.cantonal, this.regional, this.federal);

  final int cantonal;
  final int regional;
  final int federal;
}

BoutCounts boutCounts(Iterable<String> results) {
  var wins = 0, draws = 0, losses = 0;
  for (final result in results) {
    for (final c in result.split('')) {
      if (c == '+') wins++;
      if (c == '-') draws++;
      if (c == 'o') losses++;
    }
  }
  return BoutCounts(wins, draws, losses);
}

double? averageRank(List<Ranking> rankings) {
  final counted = rankings.where((r) => r.status != 'Unfall').toList();
  if (counted.length < 5) return null;
  final sum = counted.fold<int>(0, (s, r) => s + (int.tryParse(r.rank.replaceAll(RegExp(r'\D'), '')) ?? 0));
  return sum / counted.length;
}

double? averagePoints(List<Ranking> rankings) {
  final counted = rankings.where((r) => r.status != 'Unfall' && !r.place.type.contains('idgenössisch')).toList();
  if (counted.length < 5) return null;
  final sum = counted.fold<double>(0, (s, r) => s + (double.tryParse(r.points) ?? 0));
  return sum / counted.length;
}

WreathCounts wreathCounts(List<Ranking> rankings) {
  var cantonal = 0, regional = 0, federal = 0;
  for (final r in rankings.where((r) => r.wreath)) {
    switch (r.place.type) {
      case 'Gauverband' || 'Kantonal':
        cantonal++;
      case 'Teilverband' || 'Berg':
        regional++;
      case 'Eidgenössisch':
        federal++;
    }
  }
  return WreathCounts(cantonal, regional, federal);
}

int compareRanks(String rankA, String rank2A, String rankB, String rank2B) {
  final byNumber = (int.tryParse(rankA) ?? 0).compareTo(int.tryParse(rankB) ?? 0);
  return byNumber != 0 ? byNumber : rank2A.compareTo(rank2B);
}

class SeasonTrend {
  const SeasonTrend(this.year, this.counts, this.averagePoints);

  final int year;
  final BoutCounts counts;
  final double? averagePoints;

  int? get winPercent => counts.total == 0 ? null : counts.winPercent;
}

Map<int, List<Ranking>> bySeason(List<Ranking> rankings) {
  final seasons = <int, List<Ranking>>{};
  for (final r in rankings) {
    final year = int.tryParse(r.place.date.length >= 4 ? r.place.date.substring(0, 4) : '');
    if (year != null) (seasons[year] ??= []).add(r);
  }
  return Map.fromEntries(seasons.entries.toList()..sort((a, b) => a.key - b.key));
}

List<SeasonTrend> seasonTrends(List<Ranking> rankings) => [
  for (final MapEntry(key: year, value: season) in bySeason(rankings).entries)
    SeasonTrend(year, boutCounts(season.map((r) => r.result)), averagePoints(season)),
];

List<(int, num?)> yearSeries(Map<int, num?> byYear) {
  final years = [
    for (final MapEntry(:key, :value) in byYear.entries)
      if (value != null) key,
  ]..sort();
  if (years.length < 2) return const [];
  return [for (var y = years.first; y <= years.last; y++) (y, byYear[y])];
}
