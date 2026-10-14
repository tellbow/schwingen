import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/charts.dart';
import 'package:tellbow/data/models.dart';

import 'stats_test.dart' show ranking;

PlaceRanking placeRanking(String points, {bool wreath = false}) =>
    PlaceRanking(rank: '1', rank2: '', points: points, wreath: wreath, status: '', wrestler: null, bouts: const []);

void main() {
  group('festivalResults', () {
    test('sorts by date and reads rank and points', () {
      final results = festivalResults([
        ranking(date: '2025-07-06 00:00:00.000Z', rank: '3b', points: '57.25'),
        ranking(date: '2025-05-11 00:00:00.000Z', rank: '1', points: '58.75'),
      ]);
      expect(results.map((r) => (r.date.month, r.rank, r.points)), [(5, 1, 58.75), (7, 3, 57.25)]);
    });

    test('has no points for federal festivals, which have more rounds', () {
      final results = festivalResults([
        ranking(date: '2025-08-30 00:00:00.000Z', rank: '2', points: '76.75', type: 'Eidgenössisch'),
      ]);
      expect(results.map((r) => (r.rank, r.points)), [(2, null)]);
    });

    test('leaves out accidents and festivals without a date', () {
      final results = festivalResults([
        ranking(date: '2025-05-11 00:00:00.000Z', status: 'Unfall'),
        ranking(date: ''),
        ranking(date: '2025-06-01 00:00:00.000Z', rank: '', points: ''),
      ]);
      expect(results.map((r) => (r.rank, r.points)), [(null, null)]);
    });
  });

  test('averageRankBySeason needs five festivals in a season', () {
    final rankings = [
      for (final r in ['1', '2', '3', '4', '5']) ranking(date: '2024-06-01', rank: r),
      ranking(date: '2025-06-01', rank: '1'),
    ];
    expect(averageRankBySeason(rankings), {2024: 3.0, 2025: null});
  });

  group('pointsHistogram', () {
    test('counts wreaths and the rest per half point, with empty bins in between', () {
      final bins = pointsHistogram([
        placeRanking('58.75', wreath: true),
        placeRanking('58.50', wreath: true),
        placeRanking('57.25', wreath: true),
        placeRanking('57.00'),
        placeRanking('56.00'),
      ]);
      expect(bins.map((b) => (b.from, b.wreath, b.other)), [
        (56.0, 0, 1),
        (56.5, 0, 0),
        (57.0, 1, 1),
        (57.5, 0, 0),
        (58.0, 0, 0),
        (58.5, 2, 0),
      ]);
    });

    test('ignores rankings without points', () {
      expect(pointsHistogram([placeRanking(''), placeRanking('0')]), isEmpty);
    });
  });

  test('shareOfMax scales to the largest value', () {
    expect(shareOfMax([10, 5, 0]), [1.0, 0.5, 0.0]);
    expect(shareOfMax([0, 0]), [0.0, 0.0]);
  });
}
