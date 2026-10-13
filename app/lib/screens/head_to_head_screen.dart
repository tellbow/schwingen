import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/queries.dart';
import '../data/stats.dart';
import 'context.dart';
import 'stat_grid.dart';
import 'widgets.dart';
import 'wrestlers_screen.dart';

class HeadToHeadScreen extends StatefulWidget {
  const HeadToHeadScreen({super.key, required this.queries, this.first, this.second});

  final Queries queries;
  final Person? first;
  final Person? second;

  @override
  State<HeadToHeadScreen> createState() => _HeadToHeadScreenState();
}

class _HeadToHeadScreenState extends State<HeadToHeadScreen> {
  late Person? _first = widget.first;
  late Person? _second = widget.second;
  late Future<List<Meeting>>? _meetings = _load();

  Future<List<Meeting>>? _load() {
    final first = _first, second = _second;
    return first == null || second == null ? null : widget.queries.meetings(first.id, second.id);
  }

  Future<void> _pick(bool first) async {
    final person = await Navigator.of(
      context,
    ).push<Person>(MaterialPageRoute(builder: (_) => WrestlerPickerScreen(queries: widget.queries)));
    if (person == null) return;
    setState(() {
      first ? _first = person : _second = person;
      _meetings = _load();
    });
  }

  void _swap() => setState(() {
    final first = _first;
    _first = _second;
    _second = first;
    _meetings = _load();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meetings = _meetings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHeadToHead)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Picker(label: l10n.wrestler1, person: _first, onTap: () => _pick(true)),
          Center(
            child: IconButton(tooltip: l10n.swap, icon: const Icon(Icons.swap_vert), onPressed: _swap),
          ),
          _Picker(label: l10n.wrestler2, person: _second, onTap: () => _pick(false)),
          if (meetings != null)
            Loader(
              future: meetings,
              builder: (context, list) => _Meetings(queries: widget.queries, meetings: list),
            ),
        ],
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.label, required this.person, required this.onTap});

  final String label;
  final Person? person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      child: ListTile(
        title: person == null ? Text(context.l10n.pickWrestler) : PersonName(person!),
        subtitle: Text(label),
        trailing: const Icon(Icons.search),
        onTap: onTap,
      ),
    ),
  );
}

class _Meetings extends StatelessWidget {
  const _Meetings({required this.queries, required this.meetings});

  final Queries queries;
  final List<Meeting> meetings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (meetings.isEmpty) return Message(l10n.noMeetings);
    final scheme = Theme.of(context).colorScheme;
    final counts = boutCounts(meetings.map((m) => m.result));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatGrid([
          StatTile(label: l10n.wins, value: '${counts.wins}', color: scheme.tertiary),
          StatTile(label: l10n.draws, value: '${counts.draws}'),
          StatTile(label: l10n.losses, value: '${counts.losses}', color: scheme.error),
        ]),
        Section(
          title: l10n.meetings,
          children: [
            for (final m in meetings)
              ListTile(
                leading: ResultMark(m.result),
                title: Text(m.place.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${context.date(m.place.date)} · ${l10n.round(m.round)}'),
                trailing: Text(context.points(m.points), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => openPlace(context, queries, m.place.id),
              ),
          ],
        ),
      ],
    );
  }
}
