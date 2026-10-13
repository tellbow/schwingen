class Person {
  const Person({required this.id, required this.name, required this.vorname, this.symbol = ''});

  final String id;
  final String name;
  final String vorname;
  final String symbol;

  String get fullName => '$vorname $name'.trim();
}

class WrestlerSummary {
  const WrestlerSummary({required this.person, required this.year, required this.club});

  final Person person;
  final String year;
  final String club;
}

class WrestlerDetail {
  const WrestlerDetail({
    required this.person,
    required this.year,
    required this.status,
    required this.clubId,
    required this.club,
    required this.canton,
    required this.association,
    required this.website,
    required this.instagram,
  });

  final Person person;
  final String year;
  final String status;
  final String clubId;
  final String club;
  final String canton;
  final String association;
  final String website;
  final String instagram;
}

class Ranking {
  const Ranking({
    required this.rank,
    required this.rank2,
    required this.points,
    required this.result,
    required this.wreath,
    required this.status,
    required this.place,
  });

  final String rank;
  final String rank2;
  final String points;
  final String result;
  final bool wreath;
  final String status;
  final PlaceSummary place;

  String get rankLabel => '$rank$rank2';
}

class PlaceSummary {
  const PlaceSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.type,
  });

  final String id;
  final String name;
  final String location;
  final String date;
  final String type;
}

class Bout {
  const Bout({required this.round, required this.result, required this.points, required this.opponent});

  final int round;
  final String result;
  final String points;
  final Person? opponent;
}

class PlaceRanking {
  const PlaceRanking({
    required this.rank,
    required this.rank2,
    required this.points,
    required this.wreath,
    required this.status,
    required this.wrestler,
    required this.bouts,
  });

  final String rank;
  final String rank2;
  final String points;
  final bool wreath;
  final String status;
  final Person? wrestler;
  final List<Bout> bouts;

  String get rankLabel => '$rank$rank2';
}

class OpponentRecord {
  const OpponentRecord({required this.opponent, required this.wins, required this.draws, required this.losses});

  final Person opponent;
  final int wins;
  final int draws;
  final int losses;

  int get total => wins + draws + losses;
}

class Meeting {
  const Meeting({required this.round, required this.result, required this.points, required this.place});

  final int round;
  final String result;
  final String points;
  final PlaceSummary place;
}

class Elo {
  const Elo({required this.year, required this.rating});

  final int year;
  final num rating;
}

class StatEntry {
  const StatEntry({required this.person, required this.value, this.extra});

  final Person person;
  final num value;
  final num? extra;
}

class Statistics {
  const Statistics({
    required this.elo,
    required this.averageRank,
    required this.averagePoints,
    required this.mostWins,
    required this.mostWreaths,
    required this.mostPlacesAttended,
    required this.drawPercent,
  });

  final List<StatEntry> elo;
  final List<StatEntry> averageRank;
  final List<StatEntry> averagePoints;
  final List<StatEntry> mostWins;
  final List<StatEntry> mostWreaths;
  final List<StatEntry> mostPlacesAttended;
  final int? drawPercent;
}

enum GroupLevel { association, canton, club }

class Group {
  const Group({
    required this.level,
    required this.id,
    required this.name,
    required this.short,
    required this.total,
    required this.active,
    required this.stars,
  });

  final GroupLevel level;
  final String id;
  final String name;
  final String short;
  final int total;
  final int active;
  final (int, int, int) stars;
}
