import 'models.dart';
import 'stats.dart';

class WreathSummary {
  const WreathSummary(this.starters, this.wreaths, this.wreathLine);

  final int starters;
  final int wreaths;
  final double? wreathLine;

  int get wreathPercent => starters == 0 ? 0 : (wreaths * 100 / starters).round();
}

WreathSummary wreathSummary(List<PlaceRanking> rankings) {
  final points = [
    for (final r in rankings)
      if (r.wreath) ?double.tryParse(r.points),
  ];
  return WreathSummary(
    rankings.length,
    rankings.where((r) => r.wreath).length,
    points.isEmpty ? null : points.reduce((a, b) => a < b ? a : b),
  );
}

Map<int, BoutCounts> outcomesByRound(List<PlaceRanking> rankings) {
  final seen = <String>{};
  final decided = <int, int>{}, draws = <int, int>{};
  for (final r in rankings) {
    for (final b in r.bouts) {
      if (b.round <= 0 || !const ['+', '-', 'o'].contains(b.result)) continue;
      final pair = [r.wrestler?.id ?? '', b.opponent?.id ?? '']..sort();
      if (!seen.add('${b.round} ${pair.join(' ')}')) continue;
      final counter = b.result == '-' ? draws : decided;
      counter[b.round] = (counter[b.round] ?? 0) + 1;
    }
  }
  final rounds = {...decided.keys, ...draws.keys}.toList()..sort();
  return {for (final round in rounds) round: BoutCounts(decided[round] ?? 0, draws[round] ?? 0, 0)};
}

typedef Upset = ({int round, Person winner, num winnerElo, Person loser, num loserElo});

List<Upset> upsets(List<PlaceRanking> rankings, {int count = 3}) {
  final elo = {
    for (final r in rankings)
      if ((r.wrestler, r.previousElo) case (final w?, final e?)) w.id: e,
  };
  final found = <Upset>[
    for (final r in rankings)
      if ((r.wrestler, r.previousElo) case (final winner?, final winnerElo?))
        for (final b in r.bouts)
          if (b.result == '+')
            if ((b.opponent, elo[b.opponent?.id]) case (final loser?, final loserElo?) when loserElo > winnerElo)
              (round: b.round, winner: winner, winnerElo: winnerElo, loser: loser, loserElo: loserElo),
  ]..sort((a, b) => (b.loserElo - b.winnerElo).compareTo(a.loserElo - a.winnerElo));
  return found.take(count).toList();
}

typedef AssociationShare = ({String name, int starters, int wreaths});

List<AssociationShare> byAssociation(List<PlaceRanking> rankings) {
  final starters = <String, int>{}, wreaths = <String, int>{};
  for (final r in rankings.where((r) => r.association.isNotEmpty)) {
    starters[r.association] = (starters[r.association] ?? 0) + 1;
    if (r.wreath) wreaths[r.association] = (wreaths[r.association] ?? 0) + 1;
  }
  return [
    for (final MapEntry(key: name, value: n) in starters.entries)
      (name: name, starters: n, wreaths: wreaths[name] ?? 0),
  ]..sort((a, b) => b.starters - a.starters);
}
