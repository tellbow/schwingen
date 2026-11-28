import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/charts.dart';

import 'stats_test.dart' show ranking;

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

  test('monthLabels names each new month, but never on two neighbouring bars', () {
    final dates = [
      for (final (m, d) in [(2, 1), (4, 1), (4, 20), (5, 3), (6, 1), (6, 8)]) DateTime(2025, m, d),
    ];
    expect(monthLabels(dates, (d) => '${d.month}'), ['2', '', '', '5', '', '']);
    expect(monthLabels(const [], (d) => ''), isEmpty);
  });

  test('shareOfMax scales to the largest value', () {
    expect(shareOfMax([10, 5, 0]), [1.0, 0.5, 0.0]);
    expect(shareOfMax([0, 0]), [0.0, 0.0]);
  });
}
