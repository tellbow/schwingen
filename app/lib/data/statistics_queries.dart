import 'models.dart';
import 'queries.dart';
import 'rows.dart';

extension StatisticsQueries on Queries {
  Future<Statistics> statistics(int? year) async {
    final suffix = year == null ? 'Overall' : '$year';
    if (year != null && !(await seasons()).contains(year)) throw ArgumentError.value(year, 'year');
    final elo = year != null && (await eloYears()).contains(year)
        ? await _entries('''
            SELECT w.id, w.name, w.vorname, s.symbol, e.rating AS value
            FROM elo$year e
            JOIN wrestler w ON w.id = e.wrestler
            LEFT JOIN wrestlerStatus s ON s.id = w.status
            ORDER BY e.rating DESC, w.name, w.vorname
            LIMIT 5''')
        : <StatEntry>[];
    final ratio = await db.rawQuery(
      'SELECT SUM(countDraw) AS draws, SUM(countAll) AS total FROM drawDecisionRatio WHERE ? IS NULL OR yearFormat = ?',
      [year?.toString(), year?.toString()],
    );
    final total = whole(ratio.first['total']);
    return Statistics(
      elo: elo,
      averageRank: await _entries(
        'SELECT wid AS id, name, vorname, averageRank AS value FROM averageRank$suffix ORDER BY averageRank',
      ),
      averagePoints: await _entries(
        'SELECT wid AS id, name, vorname, averagePoints AS value FROM averagePoints$suffix ORDER BY averagePoints DESC',
      ),
      mostWins: await _entries(
        'SELECT id, name, vorname, wins AS value, wreath AS extra FROM mostWins$suffix ORDER BY wins DESC, wreath DESC',
      ),
      mostWreaths: await _entries(
        'SELECT id, name, vorname, wreath AS value FROM mostWreaths$suffix ORDER BY wreath DESC',
      ),
      mostPlacesAttended: await _entries(
        'SELECT id, name, vorname, placesAttended AS value FROM mostPlacesAttended$suffix ORDER BY placesAttended DESC',
      ),
      drawPercent: total == 0 ? null : (whole(ratio.first['draws']) * 100 / total).round(),
    );
  }

  Future<List<StatEntry>> _entries(String sql) async => [
    for (final r in await db.rawQuery(sql))
      StatEntry(person: personOf(r), value: (r['value'] as num?) ?? 0, extra: r['extra'] as num?),
  ];
}
