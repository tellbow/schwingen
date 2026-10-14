typedef Ring = List<(double, double)>;

class Region {
  const Region(this.name, this.rings);

  final String name;
  final List<Ring> rings;
}

const _regionAliases = {
  'Obwalden': 'Ob- und Nidwalden',
  'Nidwalden': 'Ob- und Nidwalden',
  'Appenzell Ausserrhoden': 'Appenzell',
  'Appenzell Innerrhoden': 'Appenzell',
};

List<Region> cantonRegions(Map<String, Object?> topology, Map<String, Object?> bernGauverbands) => [
  for (final region in topoRegions(topology, 'cantons'))
    if (region.name != 'Bern') Region(_regionAliases[region.name] ?? region.name, region.rings),
  ...geoRegions(bernGauverbands),
];

List<Region> topoRegions(Map<String, Object?> topology, String object) {
  final transform = topology['transform'] as Map<String, Object?>?;
  final scale = _pair(transform?['scale'], (1, 1));
  final translate = _pair(transform?['translate'], (0, 0));
  final arcs = [
    for (final arc in (topology['arcs'] as List).cast<List>())
      if (transform == null)
        [for (final p in arc.cast<List>()) _point(p)]
      else
        _decodeArc(arc.cast<List>(), scale, translate),
  ];
  Ring ring(List indexes) {
    final points = <(double, double)>[];
    for (final i in indexes.cast<int>()) {
      final arc = i >= 0 ? arcs[i] : arcs[~i].reversed.toList();
      points.addAll(points.isEmpty ? arc : arc.skip(1));
    }
    return points;
  }

  final geometries = ((topology['objects'] as Map)[object] as Map)['geometries'] as List;
  return [
    for (final g in geometries.cast<Map<String, Object?>>())
      Region(_name(g), [
        for (final polygon in _polygons(g['type'], g['arcs'] as List))
          for (final indexes in polygon) ring(indexes as List),
      ]),
  ];
}

List<Region> geoRegions(Map<String, Object?> collection) => [
  for (final f in (collection['features'] as List).cast<Map<String, Object?>>())
    if (f['geometry'] case final Map<String, Object?> geometry)
      Region(_name(f), [
        for (final polygon in _polygons(geometry['type'], geometry['coordinates'] as List))
          for (final ring in polygon) [for (final p in (ring as List).cast<List>()) _point(p)],
      ]),
];

List<List> _polygons(Object? type, List shapes) => switch (type) {
  'Polygon' => [shapes],
  'MultiPolygon' => shapes.cast<List>(),
  _ => const [],
};

String _name(Map<String, Object?> shape) => ((shape['properties'] as Map?)?['name'] ?? '').toString();

(double, double) _point(List p) => ((p[0] as num).toDouble(), (p[1] as num).toDouble());

(double, double) _pair(Object? value, (double, double) fallback) => value is List ? _point(value) : fallback;

Ring _decodeArc(List<List> arc, (double, double) scale, (double, double) translate) {
  var x = 0, y = 0;
  return [
    for (final p in arc) (scale.$1 * (x += p[0] as int) + translate.$1, scale.$2 * (y += p[1] as int) + translate.$2),
  ];
}
