import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/models.dart';
import 'package:tellbow/data/stats.dart';

Ranking ranking({
  String date = '',
  String result = '',
  String rank = '1',
  String points = '57.00',
  String status = '',
  String type = 'Kantonal',
  bool wreath = false,
}) => Ranking(
  rank: rank,
  rank2: '',
  points: points,
  result: result,
  wreath: wreath,
  status: status,
  place: PlaceSummary(id: 'p', name: 'Fest', location: '', date: date, type: type),
);

void main() {
  group('boutCounts', () {
    test('counts wins, draws and losses over all results', () {
      final counts = boutCounts(['++o-+', 'o+']);
      expect((counts.wins, counts.draws, counts.losses), (4, 1, 2));
      expect(counts.winPercent, 57);
    });

    test('has no win percentage without bouts', () {
      expect(boutCounts(['']).winPercent, 0);
      expect(boutCounts([]).total, 0);
    });
  });

  group('averageRank', () {
    test('needs five rankings that are not accidents', () {
      final four = List.generate(4, (_) => ranking(rank: '2'));
      expect(averageRank(four), isNull);
      expect(averageRank([...four, ranking(rank: '9', status: 'Unfall')]), isNull);
    });

    test('ignores letters and accidents', () {
      final rankings = [
        for (final r in ['1', '2a', '3b', '4', '5']) ranking(rank: r),
        ranking(rank: '30', status: 'Unfall'),
      ];
      expect(averageRank(rankings), 3);
    });
  });

  group('averagePoints', () {
    test('ignores federal festivals and accidents', () {
      final rankings = [
        for (final p in ['57.00', '58.00', '56.00', '57.50', '56.50']) ranking(points: p),
        ranking(points: '70.00', type: 'Eidgenössisch'),
        ranking(points: '70.00', type: 'mit eidgenössischem Charakter'),
        ranking(points: '10.00', status: 'Unfall'),
      ];
      expect(averagePoints(rankings), 57);
    });

    test('needs five rankings', () {
      expect(averagePoints([ranking()]), isNull);
    });
  });

  test('wreathCounts groups wreaths by festival type', () {
    final counts = wreathCounts([
      ranking(wreath: true, type: 'Kantonal'),
      ranking(wreath: true, type: 'Gauverband'),
      ranking(wreath: true, type: 'Berg'),
      ranking(wreath: true, type: 'Teilverband'),
      ranking(wreath: true, type: 'Eidgenössisch'),
      ranking(wreath: true, type: 'Regional'),
      ranking(wreath: false, type: 'Kantonal'),
    ]);
    expect((counts.cantonal, counts.regional, counts.federal), (2, 2, 1));
  });

  test('compareRanks sorts by number, then by letter', () {
    final ranks = [('10', ''), ('2', 'b'), ('1', ''), ('2', 'a')]..sort((a, b) => compareRanks(a.$1, a.$2, b.$1, b.$2));
    expect(ranks, [('1', ''), ('2', 'a'), ('2', 'b'), ('10', '')]);
  });

  test('seasonTrends gives each season its win rate and average points', () {
    final trends = seasonTrends([
      for (var i = 0; i < 5; i++) ranking(date: '2024-06-0${i + 1} 00:00:00.000Z', result: '++o+', points: '57.00'),
      ranking(date: '2025-05-01 00:00:00.000Z', result: '+-'),
      ranking(date: '', result: '+'),
    ]);
    expect(trends.map((t) => (t.year, t.winPercent, t.averagePoints)), [(2024, 75, 57.0), (2025, 50, null)]);
  });

  test('seasonTrends has no win rate for a season without bouts', () {
    expect(seasonTrends([ranking(date: '2023-05-01')]).single.winPercent, isNull);
  });

  group('yearSeries', () {
    test('fills the years between the first and last value, missing ones as gaps', () {
      expect(yearSeries({2019: 1400, 2021: 1450, 2022: null, 2023: 1500}), [
        (2019, 1400),
        (2020, null),
        (2021, 1450),
        (2022, null),
        (2023, 1500),
      ]);
    });

    test('is empty with fewer than two values', () {
      expect(yearSeries({2024: 1500, 2025: null}), isEmpty);
      expect(yearSeries({}), isEmpty);
    });
  });
}
