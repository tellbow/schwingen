import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/topo.dart';
import '../theme.dart';
import 'context.dart';

Future<List<Region>>? _regions;

Future<List<Region>> loadCantonRegions() => _regions ??= (() async {
  Future<Map<String, Object?>> json(String name) async =>
      jsonDecode(await rootBundle.loadString('assets/topo/$name.json')) as Map<String, Object?>;
  return cantonRegions(await json('cantons'), await json('bern-gauverband'));
})();

class MapArea {
  const MapArea({required this.label, required this.value, required this.onOpen});

  final String label;
  final int value;
  final VoidCallback onOpen;
}

class CantonMap extends StatefulWidget {
  const CantonMap({super.key, required this.regions, required this.areas});

  final List<Region> regions;
  final Map<String, MapArea> areas;

  @override
  State<CantonMap> createState() => _CantonMapState();
}

class _CantonMapState extends State<CantonMap> {
  late final _projected = [
    for (final region in widget.regions)
      [
        for (final ring in region.rings) [for (final (lon, lat) in ring) Offset(lon * cos(46.8 * pi / 180), -lat)],
      ],
  ];
  late final _bounds = _projected
      .expand((r) => r.expand((ring) => ring))
      .fold<Rect?>(
        null,
        (rect, p) => rect == null ? Rect.fromPoints(p, p) : rect.expandToInclude(Rect.fromPoints(p, p)),
      )!;
  String? _selected;

  List<Path> _paths(Size size) {
    final scale = min(size.width / _bounds.width, size.height / _bounds.height);
    final offset = Offset(
      (size.width - _bounds.width * scale) / 2 - _bounds.left * scale,
      (size.height - _bounds.height * scale) / 2 - _bounds.top * scale,
    );
    Path path(List<List<Offset>> rings) {
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final ring in rings) {
        path.addPolygon([for (final p in ring) p * scale + offset], true);
      }
      return path;
    }

    return [for (final rings in _projected) path(rings)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final top = widget.areas.values.fold(0, (m, a) => max(m, a.value));
    final selected = widget.areas.values.where((a) => a.label == _selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: AspectRatio(
            aspectRatio: _bounds.width / _bounds.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final paths = _paths(constraints.biggest);
                final fills = [
                  for (final region in widget.regions)
                    switch (widget.areas[region.name]) {
                      final area? => mapColor(scheme, top == 0 ? 0 : area.value / top),
                      null => scheme.surfaceContainerHigh,
                    },
                ];
                final highlighted = [
                  for (final region in widget.regions)
                    selected != null && widget.areas[region.name]?.label == selected.label,
                ];
                return GestureDetector(
                  onTapUp: (details) {
                    final hit = paths.indexWhere((path) => path.contains(details.localPosition));
                    setState(() => _selected = hit < 0 ? null : widget.areas[widget.regions[hit].name]?.label);
                  },
                  child: CustomPaint(
                    size: constraints.biggest,
                    painter: _MapPainter(
                      paths: paths,
                      fills: fills,
                      highlighted: highlighted,
                      gap: scheme.surfaceContainerLowest,
                      outline: scheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('0', style: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(colors: [mapColor(scheme, 0), mapColor(scheme, 1)]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$top', style: muted),
            ],
          ),
        ),
        if (selected == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(context.l10n.mapHint, style: muted),
          )
        else
          ListTile(
            title: Text(selected.label),
            subtitle: Text(context.l10n.activeCount(selected.value)),
            trailing: const Icon(Icons.chevron_right),
            onTap: selected.onOpen,
          ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.paths,
    required this.fills,
    required this.highlighted,
    required this.gap,
    required this.outline,
  });

  final List<Path> paths;
  final List<Color> fills;
  final List<bool> highlighted;
  final Color gap;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < paths.length; i++) {
      canvas.drawPath(paths[i], Paint()..color = fills[i]);
      canvas.drawPath(
        paths[i],
        stroke
          ..color = gap
          ..strokeWidth = 1,
      );
    }
    for (var i = 0; i < paths.length; i++) {
      if (highlighted[i]) {
        canvas.drawPath(
          paths[i],
          stroke
            ..color = outline
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.paths != paths || old.fills != fills || old.highlighted != highlighted || old.gap != gap;
}
