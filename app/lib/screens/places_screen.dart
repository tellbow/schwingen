import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/queries.dart';
import 'context.dart';
import 'widgets.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key, required this.queries, required this.onSettings});

  final Queries queries;
  final VoidCallback onSettings;

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  late final _years = widget.queries.placeYears();
  var _search = '';
  int? _year;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.tabPlaces), actions: [SettingsButton(widget.onSettings)]),
    body: Column(
      children: [
        SearchBox(hint: context.l10n.searchPlaces, onChanged: (value) => setState(() => _search = value)),
        FutureBuilder(
          future: _years,
          builder: (context, snapshot) => YearChips(
            years: snapshot.data ?? const [],
            selected: _year,
            onSelected: (year) => setState(() => _year = year),
          ),
        ),
        Expanded(
          child: PagedList<PlaceSummary>(
            key: ValueKey('$_search|$_year'),
            load: (offset) => widget.queries.places(_search, _year, offset: offset, limit: PagedList.pageSize),
            itemBuilder: (context, place) => ListTile(
              title: Text(place.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                [context.date(place.date), place.location, place.type].where((s) => s.isNotEmpty).join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPlace(context, widget.queries, place.id),
            ),
          ),
        ),
      ],
    ),
  );
}
