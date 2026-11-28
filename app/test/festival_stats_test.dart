import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/festival_stats.dart';
import 'package:tellbow/data/models.dart';

Person person(String id) => Person(id: id, name: id, vorname: '');

PlaceRanking entry(
  String id, {
  String points = '57.00',
  bool wreath = false,
  String association = '',
  num? elo,
  List<Bout> bouts = const [],
}) => PlaceRanking(
  rank: '1',
  rank2: '',
  points: points,
  wreath: wreath,
  status: '',
  wrestler: person(id),
  bouts: bouts,
  association: association,
  previousElo: elo,
);

Bout bout(int round, String result, String opponent) =>
    Bout(round: round, result: result, points: '9.00', opponent: person(opponent));

void main() {
  group('wreathSummary', () {
    test('counts starters, wreaths and the lowest points with a wreath', () {
      final s = wreathSummary([
        entry('a', points: '58.75', wreath: true),
        entry('b', points: '56.75', wreath: true),
        entry('c', points: '56.50'),
        entry('d', points: '12.00'),
      ]);
      expect((s.starters, s.wreaths, s.wreathLine, s.wreathPercent), (4, 2, 56.75, 50));
    });

    test('has no wreath line without wreaths', () {
      final s = wreathSummary([entry('a')]);
      expect((s.wreaths, s.wreathLine, s.wreathPercent), (0, null, 0));
      expect(wreathSummary(const []).wreathPercent, 0);
    });
  });

  test('outcomesByRound counts each bout once, from either side', () {
    final rounds = outcomesByRound([
      entry('a', bouts: [bout(1, '+', 'b'), bout(2, '-', 'c')]),
      entry('b', bouts: [bout(1, 'o', 'a'), bout(2, '+', 'x')]),
      entry('c', bouts: [bout(2, '-', 'a'), bout(0, '+', 'b'), bout(3, '', 'b')]),
    ]);
    expect(
      {for (final MapEntry(:key, :value) in rounds.entries) key: (value.wins, value.draws)},
      {1: (1, 0), 2: (1, 1)},
    );
  });

  group('upsets', () {
    test('lists wins over a higher previous-season ELO, biggest gap first', () {
      final found = upsets([
        entry('a', elo: 1400, bouts: [bout(1, '+', 'b'), bout(2, '+', 'c'), bout(3, '+', 'd')]),
        entry('b', elo: 1500),
        entry('c', elo: 1600),
        entry('d', elo: 1300),
        entry('e', bouts: [bout(1, '+', 'c')]),
        entry('f', elo: 1000, bouts: [bout(1, 'o', 'c'), bout(2, '+', 'g')]),
      ]);
      expect(found.map((u) => (u.round, u.winner.id, u.loser.id, u.loserElo - u.winnerElo)), [
        (2, 'a', 'c', 200),
        (1, 'a', 'b', 100),
      ]);
    });

    test('keeps the biggest three', () {
      final found = upsets([
        entry(
          'a',
          elo: 1000,
          bouts: [
            for (final (i, o) in ['b', 'c', 'd', 'e'].indexed) bout(i + 1, '+', o),
          ],
        ),
        for (final (i, o) in ['b', 'c', 'd', 'e'].indexed) entry(o, elo: 1100 + i * 10),
      ]);
      expect(found.map((u) => u.loser.id), ['e', 'd', 'c']);
    });
  });

  test('byAssociation counts starters and wreaths, largest first, without unknown ones', () {
    expect(
      byAssociation([
        entry('a', association: 'BKSV', wreath: true),
        entry('b', association: 'SWSV', wreath: true),
        entry('c', association: 'SWSV', wreath: true),
        entry('d', association: 'SWSV'),
        entry('e'),
      ]),
      [(name: 'SWSV', starters: 3, wreaths: 2), (name: 'BKSV', starters: 1, wreaths: 1)],
    );
  });
}
