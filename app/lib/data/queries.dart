import 'package:sqflite/sqflite.dart';

import 'models.dart';
import 'stats.dart';

typedef _Row = Map<String, Object?>;

class Queries {
  Queries(this.db);

  final DatabaseExecutor db;

  Future<List<WrestlerSummary>> wrestlers(String search, {int limit = 50, int offset = 0}) async {
    final match = matchWords(search, ['w.name', 'w.vorname', 'c.name']);
    final rows = await db.rawQuery(
      '''
      SELECT w.id, w.name, w.vorname, w.year, c.name AS club, s.symbol
      FROM wrestler w
      LEFT JOIN club c ON c.id = w.club
      LEFT JOIN wrestlerStatus s ON s.id = w.status
      WHERE ${match.where}
      ORDER BY s.symbol DESC, w.name, w.vorname
      LIMIT ? OFFSET ?''',
      [...match.args, limit, offset],
    );
    return [
      for (final r in rows) WrestlerSummary(person: _person(r), year: yearOf(_s(r['year'])), club: _s(r['club'])),
    ];
  }

  Future<WrestlerDetail?> wrestler(String id) async {
    final rows = await db.rawQuery(
      '''
      SELECT w.id, w.name, w.vorname, w.year, s.status, s.symbol, m.website, m.instagram,
        c.name AS club, ca.name AS canton, a.abbreviation AS association
      FROM wrestler w
      LEFT JOIN wrestlerStatus s ON s.id = w.status
      LEFT JOIN wrestlerMetadata m ON m.id = w.metadata
      LEFT JOIN club c ON c.id = w.club
      LEFT JOIN canton ca ON ca.id = c.canton
      LEFT JOIN association a ON a.id = ca.association
      WHERE w.id = ?''',
      [id],
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return WrestlerDetail(
      person: _person(r),
      year: yearOf(_s(r['year'])),
      status: _s(r['status']),
      club: _s(r['club']),
      canton: _s(r['canton']),
      association: _s(r['association']),
      website: _s(r['website']),
      instagram: _s(r['instagram']),
    );
  }

  Future<List<int>> seasons() => _yearsOf('mostWins');

  Future<List<int>> eloYears() => _yearsOf('elo', type: 'table');

  Future<Elo?> elo(String wrestlerId, int? year) async {
    final available = await eloYears();
    for (final y in available.where((y) => year == null || y == year)) {
      final rows = await db.rawQuery('SELECT rating FROM elo$y WHERE wrestler = ? LIMIT 1', [wrestlerId]);
      if (rows.isNotEmpty) return Elo(year: y, rating: rows.first['rating'] as num);
    }
    return null;
  }

  Future<List<Ranking>> rankingsOf(String wrestlerId, int? year) async {
    final range = _yearRange(year);
    final rows = await db.rawQuery(
      '''
      SELECT r.rank, r.rank2, r.points, r.result, r.wreath, r.status,
        p.id AS placeId, p.name AS placeName, p.location, p.year AS date, t.type
      FROM rankings r
      JOIN places p ON p.id = r.place
      LEFT JOIN placeType t ON t.id = p.placeType
      WHERE r.wrestler = ? AND ${range.where}
      ORDER BY p.year DESC, r.created DESC''',
      [wrestlerId, ...range.args],
    );
    return [
      for (final r in rows)
        Ranking(
          rank: _s(r['rank']),
          rank2: _s(r['rank2']),
          points: _s(r['points']),
          result: _s(r['result']),
          wreath: r['wreath'] == 1,
          status: _s(r['status']),
          place: _place(r),
        ),
    ];
  }

  Future<List<OpponentRecord>> opponents(String wrestlerId, int? year, {int limit = 20}) async {
    final range = _yearRange(year);
    final rows = await db.rawQuery(
      '''
      SELECT o.id, o.name, o.vorname, s.symbol,
        SUM(b.result = '+') AS wins, SUM(b.result = '-') AS draws, SUM(b.result = 'o') AS losses
      FROM bouts b
      JOIN places p ON p.id = b.place
      JOIN wrestler o ON o.id = b.opponent
      LEFT JOIN wrestlerStatus s ON s.id = o.status
      WHERE b.wrestler = ? AND ${range.where}
      GROUP BY o.id
      ORDER BY COUNT(*) DESC, o.name, o.vorname
      LIMIT ?''',
      [wrestlerId, ...range.args, limit],
    );
    return [
      for (final r in rows)
        OpponentRecord(opponent: _person(r), wins: _i(r['wins']), draws: _i(r['draws']), losses: _i(r['losses'])),
    ];
  }

  Future<List<int>> placeYears() async {
    final rows = await db.rawQuery(
      "SELECT DISTINCT CAST(substr(year, 1, 4) AS INTEGER) AS y FROM places WHERE year != '' ORDER BY y DESC",
    );
    return [for (final r in rows) r['y'] as int];
  }

  Future<List<PlaceSummary>> places(String search, int? year, {int limit = 50, int offset = 0}) async {
    final match = matchWords(search, ['p.name', 'p.location']);
    final range = _yearRange(year);
    final rows = await db.rawQuery(
      '''
      SELECT p.id AS placeId, p.name AS placeName, p.location, p.year AS date, t.type
      FROM places p
      LEFT JOIN placeType t ON t.id = p.placeType
      WHERE ${match.where} AND ${range.where}
      ORDER BY p.year DESC, p.name
      LIMIT ? OFFSET ?''',
      [...match.args, ...range.args, limit, offset],
    );
    return [for (final r in rows) _place(r)];
  }

  Future<PlaceSummary?> place(String id) async {
    final rows = await db.rawQuery(
      '''
      SELECT p.id AS placeId, p.name AS placeName, p.location, p.year AS date, t.type
      FROM places p
      LEFT JOIN placeType t ON t.id = p.placeType
      WHERE p.id = ?''',
      [id],
    );
    return rows.isEmpty ? null : _place(rows.first);
  }

  Future<List<PlaceRanking>> placeRankings(String placeId) async {
    final boutRows = await db.rawQuery(
      '''
      SELECT b.wrestler, b.fight_round, b.result, b.points, o.id, o.name, o.vorname, s.symbol
      FROM bouts b
      LEFT JOIN wrestler o ON o.id = b.opponent
      LEFT JOIN wrestlerStatus s ON s.id = o.status
      WHERE b.place = ?
      ORDER BY b.fight_round''',
      [placeId],
    );
    final bouts = <String, List<Bout>>{};
    for (final r in boutRows) {
      (bouts[_s(r['wrestler'])] ??= []).add(
        Bout(
          round: _i(r['fight_round']),
          result: _s(r['result']),
          points: _s(r['points']),
          opponent: r['id'] == null ? null : _person(r),
        ),
      );
    }
    final rows = await db.rawQuery(
      '''
      SELECT r.rank, r.rank2, r.points, r.wreath, r.status, w.id, w.name, w.vorname, s.symbol
      FROM rankings r
      LEFT JOIN wrestler w ON w.id = r.wrestler
      LEFT JOIN wrestlerStatus s ON s.id = w.status
      WHERE r.place = ?''',
      [placeId],
    );
    final rankings = [
      for (final r in rows)
        PlaceRanking(
          rank: _s(r['rank']),
          rank2: _s(r['rank2']),
          points: _s(r['points']),
          wreath: r['wreath'] == 1,
          status: _s(r['status']),
          wrestler: r['id'] == null ? null : _person(r),
          bouts: bouts[_s(r['id'])] ?? const [],
        ),
    ];
    rankings.sort((a, b) => compareRanks(a.rank, a.rank2, b.rank, b.rank2));
    return rankings;
  }

  Future<List<Meeting>> meetings(String wrestlerId, String opponentId) async {
    final rows = await db.rawQuery(
      '''
      SELECT b.fight_round, b.result, b.points, p.id AS placeId, p.name AS placeName, p.location, p.year AS date, t.type
      FROM bouts b
      JOIN places p ON p.id = b.place
      LEFT JOIN placeType t ON t.id = p.placeType
      WHERE b.wrestler = ? AND b.opponent = ?
      ORDER BY p.year DESC, b.fight_round DESC''',
      [wrestlerId, opponentId],
    );
    return [
      for (final r in rows)
        Meeting(round: _i(r['fight_round']), result: _s(r['result']), points: _s(r['points']), place: _place(r)),
    ];
  }

  Future<Statistics> statistics(int? year) async {
    final suffix = year == null ? 'Overall' : '$year';
    if (year != null && !(await seasons()).contains(year)) throw ArgumentError.value(year, 'year');
    final elo = year != null && (await eloYears()).contains(year)
        ? await _entries('''
            SELECT w.id, w.name, w.vorname, s.symbol, e.rating AS value
            FROM elo$year e
            JOIN wrestler w ON w.id = e.wrestler
            LEFT JOIN wrestlerStatus s ON s.id = w.status
            ORDER BY e.rating DESC, e.created DESC
            LIMIT 5''')
        : <StatEntry>[];
    final ratio = await db.rawQuery(
      'SELECT SUM(countDraw) AS draws, SUM(countAll) AS total FROM drawDecisionRatio WHERE ? IS NULL OR yearFormat = ?',
      [year?.toString(), year?.toString()],
    );
    final total = _i(ratio.first['total']);
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
      drawPercent: total == 0 ? null : (_i(ratio.first['draws']) * 100 / total).round(),
    );
  }

  Future<List<StatEntry>> _entries(String sql) async => [
    for (final r in await db.rawQuery(sql))
      StatEntry(person: _person(r), value: (r['value'] as num?) ?? 0, extra: r['extra'] as num?),
  ];

  Future<List<int>> _yearsOf(String prefix, {String type = 'view'}) async {
    final rows = await db.rawQuery("SELECT name FROM sqlite_master WHERE type = ? AND name GLOB ?", [
      type,
      '$prefix[0-9][0-9][0-9][0-9]',
    ]);
    return [for (final r in rows) int.parse(_s(r['name']).substring(prefix.length))]..sort((a, b) => b - a);
  }
}

({String where, List<Object> args}) matchWords(String search, List<String> columns) {
  final words = search.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return (where: '1', args: const []);
  return (
    where: words.map((_) => '(${columns.map((c) => "$c LIKE ? ESCAPE '\\'").join(' OR ')})').join(' AND '),
    args: [
      for (final w in words)
        for (final _ in columns) '%${w.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}')}%',
    ],
  );
}

String yearOf(String date) => date.length >= 4 ? date.substring(0, 4) : '';

({String where, List<Object> args}) _yearRange(int? year) => year == null
    ? (where: '1', args: const [])
    : (where: 'p.year >= ? AND p.year < ?', args: ['$year-01-01', '${year + 1}-01-01']);

Person _person(_Row r) =>
    Person(id: _s(r['id']), name: _s(r['name']), vorname: _s(r['vorname']), symbol: _s(r['symbol']));

PlaceSummary _place(_Row r) => PlaceSummary(
  id: _s(r['placeId']),
  name: _s(r['placeName']),
  location: _s(r['location']),
  date: _s(r['date']),
  type: _s(r['type']),
);

String _s(Object? v) => v?.toString() ?? '';

int _i(Object? v) => (v as num?)?.toInt() ?? 0;
