import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/models.dart';
import 'package:tellbow/data/stats.dart';

Ranking ranking({
  String rank = '1',
  String points = '57.00',
  String status = '',
  String type = 'Kantonal',
  bool wreath = false,
}) => Ranking(
  rank: rank,
  rank2: '',
  points: points,
  result: '',
  wreath: wreath,
  status: status,
  place: PlaceSummary(id: 'p', name: 'Fest', location: '', date: '', type: type),
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
}
