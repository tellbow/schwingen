import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/queries.dart';
import 'context.dart';
import 'widgets.dart';

class WrestlersScreen extends StatelessWidget {
  const WrestlersScreen({super.key, required this.queries});

  final Queries queries;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.tabWrestlers)),
    body: WrestlerSearch(queries: queries, onPick: (person) => openWrestler(context, queries, person.id)),
  );
}

class WrestlerPickerScreen extends StatelessWidget {
  const WrestlerPickerScreen({super.key, required this.queries});

  final Queries queries;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.pickWrestler)),
    body: WrestlerSearch(queries: queries, autofocus: true, onPick: (person) => Navigator.of(context).pop(person)),
  );
}

class WrestlerSearch extends StatefulWidget {
  const WrestlerSearch({super.key, required this.queries, required this.onPick, this.autofocus = false});

  final Queries queries;
  final ValueChanged<Person> onPick;
  final bool autofocus;

  @override
  State<WrestlerSearch> createState() => _WrestlerSearchState();
}

class _WrestlerSearchState extends State<WrestlerSearch> {
  var _search = '';

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SearchBox(
        hint: context.l10n.searchWrestlers,
        autofocus: widget.autofocus,
        onChanged: (value) => setState(() => _search = value),
      ),
      Expanded(
        child: PagedList<WrestlerSummary>(
          key: ValueKey(_search),
          load: (offset) => widget.queries.wrestlers(_search, offset: offset, limit: PagedList.pageSize),
          itemBuilder: (context, wrestler) => ListTile(
            title: PersonName(wrestler.person),
            subtitle: Text([wrestler.club, wrestler.year].where((s) => s.isNotEmpty).join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onPick(wrestler.person),
          ),
        ),
      ),
    ],
  );
}
