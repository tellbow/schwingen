import 'models.dart';

typedef Row = Map<String, Object?>;

Person personOf(Row r) =>
    Person(id: text(r['id']), name: text(r['name']), vorname: text(r['vorname']), symbol: text(r['symbol']));

PlaceSummary placeOf(Row r) => PlaceSummary(
  id: text(r['placeId']),
  name: text(r['placeName']),
  location: text(r['location']),
  date: text(r['date']),
  type: text(r['type']),
);

String text(Object? v) => v?.toString() ?? '';

int whole(Object? v) => (v as num?)?.toInt() ?? 0;
