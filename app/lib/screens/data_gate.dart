import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../data/queries.dart';
import '../data/release.dart';
import '../data/store.dart';
import 'context.dart';
import 'home_screen.dart';
import 'widgets.dart';

const _backup = MethodChannel('tellbow/backup');

Future<DataStore> openStore() async {
  final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'data'));
  await dir.create(recursive: true);
  await _backup.invokeMethod('exclude', dir.path);
  return DataStore(dir, http.Client());
}

class DataGate extends StatefulWidget {
  const DataGate({super.key, required this.store});

  final Future<DataStore> store;

  @override
  State<DataGate> createState() => _DataGateState();
}

class _DataGateState extends State<DataGate> {
  DataStore? _store;
  Database? _db;
  Queries? _queries;
  Release? _release;
  double? _progress;
  Object? _error;
  var _checking = false;
  var _dismissed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final store = _store = await widget.store;
      if (store.installed) await _open();
      await _check();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _open() async {
    final db = await openReadOnlyDatabase(_store!.database.path);
    if (!mounted) return db.close();
    setState(() {
      _db = db;
      _queries = Queries(db);
    });
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final release = await _store!.newerRelease();
      if (mounted) setState(() => _release = release);
    } catch (e) {
      if (mounted && _queries == null) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _download() async {
    final store = _store!, release = _release!;
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      final fetched = await store.fetch(release, (value) {
        if (mounted) setState(() => _progress = value);
      });
      final old = _db;
      setState(() {
        _db = null;
        _queries = null;
      });
      await old?.close();
      try {
        await store.swap(fetched, release);
        _release = null;
      } finally {
        if (store.database.existsSync()) await _open();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queries = _queries;
    if (queries == null) return _firstDownload(context);
    final showBanner = _progress != null || (_release != null && !_dismissed);
    return HomeScreen(
      key: ObjectKey(queries),
      queries: queries,
      dataTag: _store?.installedTag,
      banner: showBanner ? _banner(context) : null,
    );
  }

  Widget _firstDownload(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final release = _release, progress = _progress, error = _error;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.appTitle, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.dataTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              if (release != null) Text(l10n.dataText(_megabytes(release))),
              const SizedBox(height: 24),
              if (progress != null) ...[
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 8),
                Text(l10n.downloading((progress * 100).floor())),
              ] else if (_checking || _store == null && error == null) ...[
                const Spinner(),
                Text(l10n.checking, textAlign: TextAlign.center),
              ] else ...[
                if (error != null) Text(l10n.failed('$error'), style: TextStyle(color: theme.colorScheme.error)),
                if (error == null && release == null) Text(l10n.noRelease),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: release == null ? _check : _download,
                  child: Text(release == null || error != null ? l10n.retry : l10n.download),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _banner(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final release = _release, progress = _progress, error = _error;
    return Material(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: progress != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.downloading((progress * 100).floor())),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: progress),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      error != null
                          ? l10n.failed('$error')
                          : l10n.updateAvailable(release?.tag ?? '', release == null ? 0 : _megabytes(release)),
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ),
                  TextButton(onPressed: () => setState(() => _dismissed = true), child: Text(l10n.later)),
                  FilledButton(onPressed: _download, child: Text(error != null ? l10n.retry : l10n.download)),
                ],
              ),
      ),
    );
  }
}

int _megabytes(Release release) => (release.size / 1000000).round();
