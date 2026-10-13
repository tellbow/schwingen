import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tellbow/data/group_queries.dart';
import 'package:tellbow/data/models.dart';
import 'package:tellbow/data/queries.dart';
import 'package:tellbow/data/statistics_queries.dart';

const schema = [
  'CREATE TABLE association (id TEXT PRIMARY KEY, name TEXT, abbreviation TEXT)',
  'CREATE TABLE canton (id TEXT PRIMARY KEY, name TEXT, association TEXT)',
  'CREATE TABLE club (id TEXT PRIMARY KEY, name TEXT, canton TEXT)',
  'CREATE TABLE wrestlerStatus (id TEXT PRIMARY KEY, status TEXT, symbol TEXT)',
  'CREATE TABLE wrestlerMetadata (id TEXT PRIMARY KEY, website TEXT, instagram TEXT)',
  'CREATE TABLE wrestler (id TEXT PRIMARY KEY, name TEXT, vorname TEXT, year TEXT, category TEXT, club TEXT, status TEXT, '
      'metadata TEXT)',
  'CREATE TABLE placeType (id TEXT PRIMARY KEY, type TEXT)',
  'CREATE TABLE places (id TEXT PRIMARY KEY, name TEXT, location TEXT, year TEXT, placeType TEXT)',
  'CREATE TABLE rankings (id TEXT PRIMARY KEY, place TEXT, wrestler TEXT, rank TEXT, rank2 TEXT, '
      'points TEXT, result TEXT, wreath BOOLEAN, final BOOLEAN, status TEXT)',
  'CREATE TABLE bouts (place TEXT, wrestler TEXT, opponent TEXT, fight_round NUMERIC, result TEXT, points TEXT)',
  'CREATE TABLE elo2024 (wrestler TEXT, rating NUMERIC)',
  'CREATE TABLE elo2025 (wrestler TEXT, rating NUMERIC)',
  "CREATE VIEW mostWins2025 AS SELECT w.id, w.name, w.vorname, COUNT(*) AS wins, SUM(r.wreath) AS wreath "
      "FROM rankings r JOIN wrestler w ON w.id = r.wrestler WHERE r.rank = '1' GROUP BY w.id",
  "CREATE VIEW mostWinsOverall AS SELECT * FROM mostWins2025",
  "CREATE VIEW mostWreaths2025 AS SELECT w.id, w.name, w.vorname, SUM(r.wreath) AS wreath "
      "FROM rankings r JOIN wrestler w ON w.id = r.wrestler GROUP BY w.id",
  "CREATE VIEW mostWreathsOverall AS SELECT * FROM mostWreaths2025",
  "CREATE VIEW mostPlacesAttended2025 AS SELECT w.id, w.name, w.vorname, COUNT(*) AS placesAttended "
      "FROM rankings r JOIN wrestler w ON w.id = r.wrestler GROUP BY w.id",
  "CREATE VIEW mostPlacesAttendedOverall AS SELECT * FROM mostPlacesAttended2025",
  "CREATE VIEW averageRank2025 AS SELECT w.id AS wid, w.name, w.vorname, AVG(r.rank) AS averageRank "
      "FROM rankings r JOIN wrestler w ON w.id = r.wrestler GROUP BY w.id",
  "CREATE VIEW averageRankOverall AS SELECT * FROM averageRank2025",
  "CREATE VIEW averagePoints2025 AS SELECT w.id AS wid, w.name, w.vorname, AVG(r.points) AS averagePoints "
      "FROM rankings r JOIN wrestler w ON w.id = r.wrestler GROUP BY w.id",
  "CREATE VIEW averagePointsOverall AS SELECT * FROM averagePoints2025",
  "CREATE VIEW drawDecisionRatio AS SELECT SUM(r.result LIKE '%-') AS countDraw, COUNT(*) AS countAll, "
      "strftime('%Y', p.year) AS yearFormat FROM rankings r JOIN places p ON p.id = r.place WHERE r.final GROUP BY yearFormat",
];

const data = [
  "INSERT INTO association VALUES ('a1', 'Bernisch-Kantonaler', 'BKSV')",
  "INSERT INTO canton VALUES ('c1', 'Bern', 'a1')",
  "INSERT INTO club VALUES ('k1', 'Schwingklub Thun', 'c1'), ('k2', 'Schwingklub Sense', 'c1')",
  "INSERT INTO wrestlerStatus VALUES ('s3', 'Eidgenoss', '***'), ('s1', 'Kantonalkranzer', '*')",
  "INSERT INTO wrestlerMetadata VALUES ('m1', 'https://example.test', '')",
  "INSERT INTO wrestler VALUES "
      "('w1', 'Staudenmann', 'Fabian', '1995-01-01 00:00:00.000Z', 'A', 'k1', 's3', 'm1'), "
      "('w2', 'Aebersold', 'Fabio', '1998-01-01 00:00:00.000Z', 'A', 'k1', 's1', ''), "
      "('w3', 'Muster_Mann', 'Hans', '', '', 'k2', '', ''), "
      "('w4', 'Aebi', 'Res', '', 'A', '', '', '')",
  "INSERT INTO placeType VALUES ('t1', 'Kantonal'), ('t2', 'Eidgenössisch')",
  "INSERT INTO places VALUES "
      "('p1', 'Emmentalisches', 'Langnau', '2025-05-11 00:00:00.000Z', 't1'), "
      "('p2', 'Eidgenössisches', 'Mollis', '2025-08-30 00:00:00.000Z', 't2'), "
      "('p3', 'Oberländisches', 'Thun', '2024-06-01 00:00:00.000Z', 't1')",
  "INSERT INTO rankings VALUES "
      "('r1', 'p1', 'w1', '1', '', '58.25', '++++-+', 1, 1, ''), "
      "('r2', 'p1', 'w2', '2', 'a', '57.00', 'o+++++', 1, 1, ''), "
      "('r3', 'p1', 'w3', '2', 'b', '56.75', '+o+++', 0, 0, ''), "
      "('r4', 'p1', 'w4', '10', '', '54.00', 'ooo', 0, 0, 'Unfall'), "
      "('r5', 'p2', 'w1', '1', '', '77.00', '+++++++-', 1, 1, ''), "
      "('r6', 'p3', 'w1', '3', '', '57.00', '++o+++', 1, 0, '')",
  "INSERT INTO bouts VALUES "
      "('p1', 'w1', 'w2', 1, '+', '10.00'), ('p1', 'w2', 'w1', 1, 'o', '8.75'), "
      "('p1', 'w1', 'w3', 2, '+', '9.75'), ('p1', 'w3', 'w1', 2, 'o', '8.50'), "
      "('p3', 'w1', 'w2', 3, 'o', '8.75'), ('p3', 'w2', 'w1', 3, '+', '10.00'), "
      "('p2', 'w1', 'w2', 6, '-', '9.00'), ('p2', 'w2', 'w1', 6, '-', '9.00')",
  "INSERT INTO elo2024 VALUES ('w1', 1490), ('w4', 1300)",
  "INSERT INTO elo2025 VALUES ('w1', 1520), ('w2', 1501)",
];

void main() {
  late Database db;
  late Queries q;

  setUpAll(() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    for (final sql in [...schema, ...data]) {
      await db.execute(sql);
    }
    q = Queries(db);
  });

  tearDownAll(() => db.close());

  group('wrestlers', () {
    test('sorts by status symbol, then by name', () async {
      final names = (await q.wrestlers('')).map((w) => w.person.name);
      expect(names, ['Staudenmann', 'Aebersold', 'Aebi', 'Muster_Mann']);
    });

    test('matches every word against name, first name or club', () async {
      expect((await q.wrestlers('fabian stauden')).map((w) => w.person.id), ['w1']);
      expect((await q.wrestlers('thun')).map((w) => w.person.id), ['w1', 'w2']);
      expect((await q.wrestlers('fab')).map((w) => w.person.id), ['w1', 'w2']);
      expect(await q.wrestlers('nobody'), isEmpty);
    });

    test('takes LIKE wildcards literally', () async {
      expect((await q.wrestlers('_')).map((w) => w.person.id), ['w3']);
      expect(await q.wrestlers('%'), isEmpty);
    });

    test('pages with limit and offset', () async {
      expect((await q.wrestlers('', limit: 2, offset: 1)).map((w) => w.person.id), ['w2', 'w4']);
    });

    test('shows year of birth and club', () async {
      final first = (await q.wrestlers('staudenmann')).single;
      expect((first.year, first.club, first.person.symbol), ('1995', 'Schwingklub Thun', '***'));
    });
  });

  test('wrestler joins status, club, canton, association and links', () async {
    final w = await q.wrestler('w1');
    expect(w?.clubId, 'k1');
    expect(w?.person.fullName, 'Fabian Staudenmann');
    expect((w?.status, w?.club, w?.canton, w?.association), ('Eidgenoss', 'Schwingklub Thun', 'Bern', 'BKSV'));
    expect(w?.website, 'https://example.test');
    expect(await q.wrestler('missing'), isNull);
  });

  group('groups', () {
    test('count all, active and wreathed wrestlers per association', () async {
      final association = (await q.groups(GroupLevel.association)).single;
      expect((association.name, association.short), ('Bernisch-Kantonaler', 'BKSV'));
      expect((association.total, association.active, association.stars), (3, 2, (1, 0, 1)));
    });

    test('list the cantons of an association and the clubs of a canton by name', () async {
      expect((await q.groups(GroupLevel.canton, parent: 'a1')).map((g) => g.id), ['c1']);
      final clubs = await q.groups(GroupLevel.club, parent: 'c1');
      expect(clubs.map((g) => (g.name, g.total, g.active)), [('Schwingklub Sense', 1, 0), ('Schwingklub Thun', 2, 2)]);
      expect(await q.groups(GroupLevel.club, parent: 'nowhere'), isEmpty);
    });

    test('find one group by id', () async {
      expect((await q.groups(GroupLevel.club, id: 'k1')).single.name, 'Schwingklub Thun');
    });

    test('club members are wrestlers filtered by club', () async {
      expect((await q.wrestlers('', club: 'k1')).map((w) => w.person.id), ['w1', 'w2']);
      expect((await q.wrestlers('fabio', club: 'k1')).map((w) => w.person.id), ['w2']);
    });
  });

  test('seasons and elo years come from the database objects', () async {
    expect(await q.seasons(), [2025]);
    expect(await q.eloYears(), [2025, 2024]);
  });

  group('elo', () {
    test('takes the newest year with a rating when no year is chosen', () async {
      expect((await q.elo('w1', null))?.rating, 1520);
      final older = await q.elo('w4', null);
      expect((older?.year, older?.rating), (2024, 1300));
    });

    test('takes the chosen year only', () async {
      expect((await q.elo('w1', 2024))?.rating, 1490);
      expect(await q.elo('w2', 2024), isNull);
      expect(await q.elo('w1', 2019), isNull);
    });
  });

  test('rankingsOf lists the newest festival first and filters by year', () async {
    final all = await q.rankingsOf('w1', null);
    expect(all.map((r) => r.place.id), ['p2', 'p1', 'p3']);
    expect(all.first.place.type, 'Eidgenössisch');
    expect(all.first.wreath, isTrue);
    expect((await q.rankingsOf('w1', 2024)).map((r) => r.place.id), ['p3']);
  });

  test('opponents counts results per opponent, most frequent first', () async {
    final all = await q.opponents('w1', null);
    expect(all.map((o) => o.opponent.id), ['w2', 'w3']);
    expect((all.first.wins, all.first.draws, all.first.losses), (1, 1, 1));
    expect((await q.opponents('w1', 2024)).single.losses, 1);
  });

  test('places searches name and location, filters by year', () async {
    expect((await q.places('', null)).map((p) => p.id), ['p2', 'p1', 'p3']);
    expect((await q.places('thun', null)).map((p) => p.id), ['p3']);
    expect((await q.places('', 2025)).map((p) => p.id), ['p2', 'p1']);
    expect(await q.placeYears(), [2025, 2024]);
    expect((await q.place('p2'))?.type, 'Eidgenössisch');
  });

  test('placeRankings sorts ranks and attaches each wrestler bouts', () async {
    final rankings = await q.placeRankings('p1');
    expect(rankings.map((r) => r.rankLabel), ['1', '2a', '2b', '10']);
    final winner = rankings.first;
    expect(winner.bouts.map((b) => (b.round, b.result, b.opponent?.id)), [(1, '+', 'w2'), (2, '+', 'w3')]);
    expect(rankings.last.status, 'Unfall');
  });

  test('meetings lists bouts between two wrestlers, newest first', () async {
    final meetings = await q.meetings('w1', 'w2');
    expect(meetings.map((m) => (m.place.id, m.result)), [('p2', '-'), ('p1', '+'), ('p3', 'o')]);
    expect(await q.meetings('w3', 'w4'), isEmpty);
  });

  group('statistics', () {
    test('of a season include ELO and the share of drawn final bouts', () async {
      final stats = await q.statistics(2025);
      expect(stats.elo.map((e) => e.person.id), ['w1', 'w2']);
      expect(stats.mostWins.first.person.id, 'w1');
      expect(stats.mostWins.first.value, 2);
      expect(stats.mostWins.first.extra, 2);
      expect(stats.averageRank.first.person.id, 'w1');
      expect(stats.drawPercent, 33);
    });

    test('over all years have no ELO', () async {
      final stats = await q.statistics(null);
      expect(stats.elo, isEmpty);
      expect(stats.mostWreaths.first.person.id, 'w1');
    });

    test('reject a year without views', () {
      expect(q.statistics(2019), throwsArgumentError);
    });
  });
}
