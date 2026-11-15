import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';
import 'context.dart';

class Loader<T> extends StatelessWidget {
  const Loader({super.key, required this.future, required this.builder});

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Message(context.l10n.failed('${snapshot.error}'));
      if (snapshot.connectionState != ConnectionState.done) return const Spinner();
      return builder(context, snapshot.data as T);
    },
  );
}

class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator.adaptive()),
  );
}

class Message extends StatelessWidget {
  const Message(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}

class SearchBox extends StatefulWidget {
  const SearchBox({super.key, required this.hint, required this.onChanged, this.autofocus = false});

  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      autocorrect: false,
      textInputAction: TextInputAction.search,
      onChanged: _changed,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  _changed('');
                },
              ),
        filled: true,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    ),
  );
}

class PagedList<T> extends StatefulWidget {
  const PagedList({super.key, required this.load, required this.itemBuilder});

  static const pageSize = 50;

  final Future<List<T>> Function(int offset) load;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  State<PagedList<T>> createState() => _PagedListState<T>();
}

class _PagedListState<T> extends State<PagedList<T>> {
  final _items = <T>[];
  var _done = false;
  var _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _more();
  }

  Future<void> _more() async {
    if (_loading || _done || _error != null) return;
    _loading = true;
    try {
      final page = await widget.load(_items.length);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _done = page.length < PagedList.pageSize;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return Message(context.l10n.failed('$_error'));
    if (_items.isEmpty) return _done ? Message(context.l10n.noResults) : const Spinner();
    return ListView.separated(
      itemCount: _items.length + (_done ? 0 : 1),
      separatorBuilder: (_, _) => const Divider(indent: 16),
      itemBuilder: (context, i) {
        if (i < _items.length) return widget.itemBuilder(context, _items[i]);
        WidgetsBinding.instance.addPostFrameCallback((_) => _more());
        return const Spinner();
      },
    );
  }
}

class YearDropdown extends StatelessWidget {
  const YearDropdown({super.key, required this.years, required this.selected, required this.onSelected});

  final List<int> years;
  final int? selected;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(context.l10n.year, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 16),
        DropdownButton<int?>(
          value: selected,
          onChanged: onSelected,
          items: [
            for (final year in <int?>[null, ...years])
              DropdownMenuItem(value: year, child: Text(year == null ? context.l10n.all : '$year')),
          ],
        ),
      ],
    ),
  );
}

class SearchableSection<T> extends StatefulWidget {
  const SearchableSection({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.text,
    required this.tile,
  });

  static const pageSize = 10;

  final String title;
  final String hint;
  final List<T> items;
  final String Function(T item) text;
  final Widget Function(T item) tile;

  @override
  State<SearchableSection<T>> createState() => _SearchableSectionState<T>();
}

class _SearchableSectionState<T> extends State<SearchableSection<T>> {
  var _query = '';
  var _shown = SearchableSection.pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final words = _query.toLowerCase().split(' ').where((w) => w.isNotEmpty);
    final found = [
      for (final item in widget.items)
        if (words.every(widget.text(item).toLowerCase().contains)) item,
    ];
    return Section(
      title: widget.title,
      children: [
        if (widget.items.length > SearchableSection.pageSize)
          SearchBox(
            hint: widget.hint,
            onChanged: (value) => setState(() {
              _query = value;
              _shown = SearchableSection.pageSize;
            }),
          ),
        if (found.isEmpty) Message(l10n.noResults),
        for (final item in found.take(_shown)) widget.tile(item),
        if (found.length > _shown)
          TextButton(onPressed: () => setState(() => _shown += SearchableSection.pageSize), child: Text(l10n.showMore)),
      ],
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton(this.onPressed, {super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: context.l10n.settings, icon: const Icon(Icons.settings_outlined), onPressed: onPressed);
}

class PersonName extends StatelessWidget {
  const PersonName(this.person, {super.key, this.style});

  final Person person;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: person.fullName),
        if (person.symbol.isNotEmpty)
          TextSpan(
            text: ' ${person.symbol}',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
      ],
    ),
    style: style,
    overflow: TextOverflow.ellipsis,
  );
}

class ResultMark extends StatelessWidget {
  const ResultMark(this.result, {super.key});

  final String result;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 20,
    child: Text(
      result,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold, color: resultColor(Theme.of(context).colorScheme, result)),
    ),
  );
}

class RankBadge extends StatelessWidget {
  const RankBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section({super.key, required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}

class Points extends StatelessWidget {
  const Points({super.key, required this.points, required this.wreath});

  final String points;
  final bool wreath;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (wreath)
        Semantics(
          label: context.l10n.wreath,
          child: const ExcludeSemantics(child: Text('🌿')),
        ),
      const SizedBox(width: 4),
      Text(context.points(points), style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
