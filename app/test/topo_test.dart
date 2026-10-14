import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tellbow/data/topo.dart';

Map<String, Object?> json(String path) => jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

void main() {
  test('topoRegions joins delta-encoded arcs, reversing negative ones', () {
    final regions = topoRegions({
      'transform': {
        'scale': [0.5, 2],
        'translate': [10, 20],
      },
      'arcs': [
        [
          [0, 0],
          [2, 0],
          [0, 1],
        ],
        [
          [0, 1],
          [0, -1],
        ],
      ],
      'objects': {
        'shapes': {
          'type': 'GeometryCollection',
          'geometries': [
            {
              'type': 'Polygon',
              'properties': {'name': 'A'},
              'arcs': [
                [0, -2],
              ],
            },
            {
              'type': 'MultiPolygon',
              'properties': {'name': 'B'},
              'arcs': [
                [
                  [1],
                ],
                [
                  [0],
                ],
              ],
            },
          ],
        },
      },
    }, 'shapes');
    expect(regions.map((r) => r.name), ['A', 'B']);
    expect(regions.first.rings.single, [(10.0, 20.0), (11.0, 20.0), (11.0, 22.0), (10.0, 22.0)]);
    expect(regions.last.rings, hasLength(2));
  });

  test('geoRegions reads polygons and multipolygons, ignoring the altitude', () {
    final regions = geoRegions({
      'features': [
        {
          'properties': {'name': 'Emmental'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [
              [
                [7.5, 47.0, 800],
                [7.6, 47.0, 700],
                [7.5, 47.1, 600],
              ],
            ],
          },
        },
        {
          'properties': {'name': 'Leer'},
          'geometry': null,
        },
      ],
    });
    expect(regions.single.name, 'Emmental');
    expect(regions.single.rings.single, [(7.5, 47.0), (7.6, 47.0), (7.5, 47.1)]);
  });

  test('cantonRegions names the shipped map like the canton table', () {
    final regions = cantonRegions(json('assets/topo/cantons.json'), json('assets/topo/bern-gauverband.json'));
    final names = regions.map((r) => r.name).toSet();
    expect(names, containsAll(['Ob- und Nidwalden', 'Appenzell', 'Emmental', 'Berner-Jura', 'Zürich', 'Vaudoise']));
    expect(names, isNot(contains('Bern')));
    expect(regions.every((r) => r.rings.isNotEmpty && r.rings.every((ring) => ring.length > 3)), isTrue);
  });
}
