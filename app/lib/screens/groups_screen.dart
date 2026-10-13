import 'package:flutter/material.dart';

import '../data/group_queries.dart';
import '../data/models.dart';
import '../data/queries.dart';
import 'context.dart';
import 'stat_grid.dart';
import 'widgets.dart';

class AssociationsScreen extends StatelessWidget {
  const AssociationsScreen({super.key, required this.queries});

  final Queries queries;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.tabAssociations)),
    body: Loader(
      future: queries.groups(GroupLevel.association),
      builder: (context, associations) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [for (final group in associations) _GroupTile(queries: queries, group: group)],
      ),
    ),
  );
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.queries, required this.level, required this.id});

  final Queries queries;
  final GroupLevel level;
  final String id;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late final _group = widget.queries.groups(widget.level, id: widget.id);
  late final Future<List<Object>> _children = switch (widget.level) {
    GroupLevel.association => widget.queries.groups(GroupLevel.canton, parent: widget.id),
    GroupLevel.canton => widget.queries.groups(GroupLevel.club, parent: widget.id),
    GroupLevel.club => widget.queries.wrestlers('', club: widget.id, limit: 1000),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Loader(
        future: _group,
        builder: (context, found) {
          if (found.isEmpty) return Message(l10n.noData);
          final group = found.single;
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(group.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              StatGrid([
                StatTile(label: l10n.total, value: '${group.total}'),
                StatTile(label: l10n.active, value: '${group.active}'),
              ], columns: 2),
              StatGrid([
                StatTile(label: '***', value: '${group.stars.$1}'),
                StatTile(label: '**', value: '${group.stars.$2}'),
                StatTile(label: '*', value: '${group.stars.$3}'),
              ]),
              Loader(
                future: _children,
                builder: (context, children) => Section(
                  title: switch (widget.level) {
                    GroupLevel.association => l10n.cantons,
                    GroupLevel.canton => l10n.clubs,
                    GroupLevel.club => l10n.tabWrestlers,
                  },
                  children: [
                    if (children.isEmpty) Message(l10n.noResults),
                    for (final child in children)
                      switch (child) {
                        Group() => _GroupTile(queries: widget.queries, group: child),
                        WrestlerSummary() => ListTile(
                          title: PersonName(child.person),
                          subtitle: child.year.isEmpty ? null : Text(child.year),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => openWrestler(context, widget.queries, child.person.id),
                        ),
                        _ => const SizedBox(),
                      },
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.queries, required this.group});

  final Queries queries;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final (three, two, one) = group.stars;
    return ListTile(
      title: Text(group.short.isEmpty ? group.name : '${group.name} (${group.short})'),
      subtitle: Text('${context.l10n.activeCount(group.active)} · *** $three · ** $two · * $one'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => openGroup(context, queries, group.level, group.id),
    );
  }
}
