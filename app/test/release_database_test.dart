import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tellbow/data/queries.dart';

final _path = Platform.environment['TELLBOW_DB'];

void main() {
  late Database db;
  late Queries q;

  setUpAll(() async {
    if (_path == null) return;
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(_path!, options: OpenDatabaseOptions(readOnly: true));
    q = Queries(db);
  });

  tearDownAll(() async {
    if (_path != null) await db.close();
  });

  Future<T> timed<T>(String name, Future<T> Function() run) async {
    final watch = Stopwatch()..start();
    final result = await run();
    printOnFailure('$name: ${watch.elapsedMilliseconds} ms');
    expect(watch.elapsed, lessThan(const Duration(seconds: 3)), reason: name);
    return result;
  }

  test(
    'every query runs against a release data.db',
    skip: _path == null ? 'set TELLBOW_DB to a release data.db' : false,
    () async {
      final seasons = await timed('seasons', q.seasons);
      expect(seasons, containsAll([2015, 2025]));
      expect(seasons, isNot(contains(2020)));

      final found = await timed('wrestlers', () => q.wrestlers('staudenmann fabian'));
      expect(found, isNotEmpty);
      final id = found.first.person.id;
      expect((await timed('wrestler', () => q.wrestler(id)))?.person.name, 'Staudenmann');

      final rankings = await timed('rankingsOf', () => q.rankingsOf(id, null));
      expect(rankings, isNotEmpty);
      expect(await timed('rankingsOf year', () => q.rankingsOf(id, 2025)), isNotEmpty);
      expect(await timed('elo', () => q.elo(id, null)), isNotNull);

      final opponents = await timed('opponents', () => q.opponents(id, null));
      expect(opponents, isNotEmpty);
      expect(await timed('meetings', () => q.meetings(id, opponents.first.opponent.id)), isNotEmpty);

      final placeId = rankings.first.place.id;
      expect(await timed('place', () => q.place(placeId)), isNotNull);
      final ranked = await timed('placeRankings', () => q.placeRankings(placeId));
      expect(ranked.first.bouts, isNotEmpty);

      expect(await timed('places', () => q.places('', 2025)), hasLength(50));
      expect(await timed('placeYears', q.placeYears), contains(2025));

      final year = await timed('statistics 2025', () => q.statistics(2025));
      expect(year.elo, hasLength(5));
      expect(year.mostWins, hasLength(5));
      expect(year.drawPercent, isNotNull);
      final overall = await timed('statistics overall', () => q.statistics(null));
      expect(overall.averageRank, hasLength(5));
    },
  );
}
