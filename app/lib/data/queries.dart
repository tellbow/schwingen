import 'package:sqflite/sqflite.dart';

import 'models.dart';
import 'rows.dart';
import 'stats.dart';

class Queries {
  Queries(this.db);

  final DatabaseExecutor db;

  Future<List<WrestlerSummary>> wrestlers(String search, {String? club, int limit = 50, int offset = 0}) async {
    final match = matchWords(search, ['w.name', 'w.vorname', 'c.name']);
    final rows = await db.rawQuery(
      '''
      SELECT w.id, w.name, w.vorname, w.year, c.name AS club, s.symbol
      FROM wrestler w
      LEFT JOIN club c ON c.id = w.club
      LEFT JOIN wrestlerStatus s ON s.id = w.status
      WHERE ${match.where} AND (? IS NULL OR w.club = ?)
      ORDER BY s.symbol DESC, w.name, w.vorname
      LIMIT ? OFFSET ?''',
      [...match.args, club, club, limit, offset],
    );
    return [
      for (final r in rows) WrestlerSummary(person: personOf(r), year: yearOf(text(r['year'])), club: text(r['club'])),
    ];
  }

  Future<WrestlerDetail?> wrestler(String id) async {
    final rows = await db.rawQuery(
      '''
      SELECT w.id, w.name, w.vorname, w.year, s.status, s.symbol, m.website, m.instagram,
        c.id AS clubId, c.name AS club, ca.name AS canton, a.abbreviation AS association
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
      person: personOf(r),
      year: yearOf(text(r['year'])),
      status: text(r['status']),
      clubId: text(r['clubId']),
      club: text(r['club']),
      canton: text(r['canton']),
      association: text(r['association']),
      website: text(r['website']),
      instagram: text(r['instagram']),
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
      ORDER BY p.year DESC, p.name''',
      [wrestlerId, ...range.args],
    );
    return [
      for (final r in rows)
        Ranking(
          rank: text(r['rank']),
          rank2: text(r['rank2']),
          points: text(r['points']),
          result: text(r['result']),
          wreath: r['wreath'] == 1,
          status: text(r['status']),
          place: placeOf(r),
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
        OpponentRecord(
          opponent: personOf(r),
          wins: whole(r['wins']),
          draws: whole(r['draws']),
          losses: whole(r['losses']),
        ),
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
    return [for (final r in rows) placeOf(r)];
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
    return rows.isEmpty ? null : placeOf(rows.first);
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
      (bouts[text(r['wrestler'])] ??= []).add(
        Bout(
          round: whole(r['fight_round']),
          result: text(r['result']),
          points: text(r['points']),
          opponent: r['id'] == null ? null : personOf(r),
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
          rank: text(r['rank']),
          rank2: text(r['rank2']),
          points: text(r['points']),
          wreath: r['wreath'] == 1,
          status: text(r['status']),
          wrestler: r['id'] == null ? null : personOf(r),
          bouts: bouts[text(r['id'])] ?? const [],
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
        Meeting(
          round: whole(r['fight_round']),
          result: text(r['result']),
          points: text(r['points']),
          place: placeOf(r),
        ),
    ];
  }

  Future<List<int>> _yearsOf(String prefix, {String type = 'view'}) async {
    final rows = await db.rawQuery("SELECT name FROM sqlite_master WHERE type = ? AND name GLOB ?", [
      type,
      '$prefix[0-9][0-9][0-9][0-9]',
    ]);
    return [for (final r in rows) int.parse(text(r['name']).substring(prefix.length))]..sort((a, b) => b - a);
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
