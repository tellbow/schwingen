import 'models.dart';
import 'queries.dart';
import 'rows.dart';

extension GroupQueries on Queries {
  Future<List<Group>> groups(GroupLevel level, {String? parent, String? id}) async {
    final (from, parentColumn, short) = switch (level) {
      GroupLevel.association => (
        'association g LEFT JOIN canton ca ON ca.association = g.id LEFT JOIN club c ON c.canton = ca.id '
            'LEFT JOIN wrestler w ON w.club = c.id',
        'NULL',
        'g.abbreviation',
      ),
      GroupLevel.canton => (
        'canton g LEFT JOIN club c ON c.canton = g.id LEFT JOIN wrestler w ON w.club = c.id',
        'g.association',
        "''",
      ),
      GroupLevel.club => ('club g LEFT JOIN wrestler w ON w.club = g.id', 'g.canton', "''"),
    };
    final rows = await db.rawQuery(
      '''
      SELECT g.id, g.name, $short AS short, COUNT(w.id) AS total,
        COUNT(CASE WHEN w.category != '' THEN 1 END) AS active,
        COUNT(CASE WHEN w.category != '' AND s.symbol = '***' THEN 1 END) AS stars3,
        COUNT(CASE WHEN w.category != '' AND s.symbol = '**' THEN 1 END) AS stars2,
        COUNT(CASE WHEN w.category != '' AND s.symbol = '*' THEN 1 END) AS stars1
      FROM $from
      LEFT JOIN wrestlerStatus s ON s.id = w.status
      WHERE (? IS NULL OR $parentColumn = ?) AND (? IS NULL OR g.id = ?)
      GROUP BY g.id
      ORDER BY g.name''',
      [parent, parent, id, id],
    );
    return [
      for (final r in rows)
        Group(
          level: level,
          id: text(r['id']),
          name: text(r['name']),
          short: text(r['short']),
          total: whole(r['total']),
          active: whole(r['active']),
          stars: (whole(r['stars3']), whole(r['stars2']), whole(r['stars1'])),
        ),
    ];
  }
}
